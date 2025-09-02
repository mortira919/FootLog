/* eslint-disable max-len, require-jsdoc, @typescript-eslint/no-explicit-any */
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {GoogleGenerativeAI} from "@google/generative-ai";

initializeApp();
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

type MsgRole = "user" | "assistant";
type MsgDoc = {
  role: MsgRole;
  text: string;
  senderId?: string;
  createdAt?: unknown;
};

// ---------- date parsing ----------
function parseDateRange(
  text: string,
): {start: Date; end: Date; key: string} | null {
  const t = text.toLowerCase().trim();
  const now = new Date();
  const toKey = (d: Date) => d.toISOString().slice(0, 10);

  const dayRange = (d: Date) => {
    const start = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const end = new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1);
    return {start, end, key: toKey(start)};
  };

  if (/(today|сегодня)/.test(t)) return dayRange(now);
  if (/(yesterday|вчера)/.test(t)) {
    return dayRange(
      new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1),
    );
  }

  // dd.mm or dd.mm.yyyy
  const m = t.match(/(\d{1,2})[.\-/ ](\d{1,2})(?:[.\-/ ](\d{2,4}))?/);
  if (m) {
    const day = parseInt(m[1], 10);
    const mon = parseInt(m[2], 10) - 1;
    const yr = m[3] ?
      (m[3].length === 2 ? parseInt("20" + m[3], 10) : parseInt(m[3], 10)) :
      now.getFullYear();
    return dayRange(new Date(yr, mon, day));
  }

  // 2 september / 2 сентября
  const monthMap: Record<string, number> = {
    january: 0, february: 1, march: 2, april: 3, may: 4, june: 5,
    july: 6, august: 7, september: 8, october: 9, november: 10, december: 11,
    январ: 0, феврал: 1, март: 2, апрел: 3, май: 4, июн: 5,
    июл: 6, август: 7, сентябр: 8, октябр: 9, ноябр: 10, декабр: 11,
  };
  const m2 = t.match(
    /(\d{1,2})\s*(январ|феврал|март|апрел|май|июн|июл|август|сентябр|октябр|ноябр|декабр|january|february|march|april|may|june|july|august|september|october|november|december)/,
  );
  if (m2) {
    const day = parseInt(m2[1], 10);
    const mon = monthMap[m2[2]];
    return dayRange(new Date(now.getFullYear(), mon, day));
  }
  return null;
}

// ---------- Firestore helpers ----------
async function fetchWellbeing(
  db: FirebaseFirestore.Firestore,
  uid: string,
  range: {start: Date; end: Date; key: string} | null,
): Promise<any | null> {
  const col = db.collection(`users/${uid}/wellbeing`);

  try {
    if (range) {
      const snap = await col
        .where("date", ">=", range.start)
        .where("date", "<", range.end)
        .orderBy("date", "desc")
        .limit(1)
        .get();
      if (!snap.empty) return snap.docs[0].data();
    }
  } catch (e) {
    logger.debug("fetchWellbeing(date range) ignored", e);
  }

  try {
    if (range) {
      const snap = await col.where("dateKey", "==", range.key).limit(1).get();
      if (!snap.empty) return snap.docs[0].data();
    }
  } catch (e) {
    logger.debug("fetchWellbeing(dateKey) ignored", e);
  }

  try {
    const snap = await col.orderBy("date", "desc").limit(1).get();
    if (!snap.empty) return snap.docs[0].data();
  } catch (e) {
    logger.debug("fetchWellbeing(latest) ignored", e);
  }

  return null;
}

async function fetchMatches(
  db: FirebaseFirestore.Firestore,
  uid: string,
  range: {start: Date; end: Date} | null,
): Promise<any[]> {
  const col = db.collection(`users/${uid}/matches`);

  try {
    if (range) {
      const q = await col
        .where("date", ">=", range.start)
        .where("date", "<", range.end)
        .orderBy("date", "desc")
        .limit(3)
        .get();
      if (!q.empty) return q.docs.map((d) => d.data());
    }
  } catch (e) {
    logger.debug("fetchMatches(date range) ignored", e);
  }

  try {
    const q = await col.orderBy("date", "desc").limit(3).get();
    if (!q.empty) return q.docs.map((d) => d.data());
  } catch (e) {
    logger.debug("fetchMatches(latest) ignored", e);
  }
  return [];
}

function summarizeWellbeing(wb: any | null): string {
  if (!wb) return "Самочувствие: записи не найдены.";
  const mood = wb.mood ?? wb.moodScore ?? "—";
  const energy = wb.energy ?? wb.energyScore ?? "—";
  const sleep = wb.sleepHours ?? wb.sleep ?? "—";
  const nutrition = wb.nutrition ?? wb.nutritionScore ?? "—";
  const injury =
    wb.injury ?? wb.injuryNotes ?? (wb.injuryStatus ? "есть жалобы" : "—");
  return [
    "Самочувствие:",
    `- Настроение: ${mood}`,
    `- Энергия: ${energy}`,
    `- Сон, часов: ${sleep}`,
    `- Питание: ${nutrition}`,
    `- Травмы/боли: ${injury}`,
  ].join("\n");
}

function summarizeMatches(list: any[]): string {
  if (!list || list.length === 0) return "Матчи: рядом с датой не найдено.";
  const lines = list.map((m: any) => {
    const opp = m.opponent ?? m.opponentTeam ?? "соперник";
    const score =
      m.yourGoals != null && m.opponentGoals != null ?
        `${m.yourGoals}:${m.opponentGoals}` :
        (m.score ?? "");
    return `• ${opp} ${score}`.trim();
  });
  return "Матчи рядом с датой:\n" + lines.join("\n");
}

async function buildFirebaseContext(
  db: FirebaseFirestore.Firestore,
  uid: string | undefined,
  userText: string,
): Promise<string | null> {
  if (!uid) return null;
  const range = parseDateRange(userText);
  const wb = await fetchWellbeing(db, uid, range);
  const matches = await fetchMatches(db, uid, range);

  const dateLabel = range ? range.key : "последняя доступная дата";
  const wbText = summarizeWellbeing(wb);
  const mText = summarizeMatches(matches);

  return [
    "Данные из БД (используй их для ответа,",
    "но не цитируй дословно и не говори, что это из БД).",
    `Дата: ${dateLabel}`,
    wbText,
    mText,
  ].join("\n");
}

// =================== main trigger ===================
export const chatReply = onDocumentCreated(
  {
    document: "chats/{chatId}/messages/{msgId}",
    region: "us-central1",
    secrets: [GEMINI_API_KEY],
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const msg = snap.data() as MsgDoc;
    if (msg.role !== "user" || !msg.text?.trim()) return;

    const db = getFirestore();
    const {chatId} = event.params as {chatId: string};

    // 1) История чата (последние 20)
    const historySnap = await db
      .collection(`chats/${chatId}/messages`)
      .orderBy("createdAt", "asc")
      .limitToLast(20)
      .get();

    const rawHistory = historySnap.docs
      .map((d) => {
        const m = d.data() as any;
        const r = m.role === "assistant" ? "model" : "user";
        const text = String(m.text ?? "");
        return {role: r as "user" | "model", parts: [{text}]};
      })
      .filter((h) => h.parts?.[0]?.text?.trim());

    // 2) Санитизируем историю: первый элемент должен быть 'user'
    let history = rawHistory;
    const firstUserIdx = rawHistory.findIndex((h) => h.role === "user");
    if (firstUserIdx > 0) history = rawHistory.slice(firstUserIdx);
    if (firstUserIdx === -1) history = [];

    // 3) uid пользователя
    let uid = (msg.senderId as string | undefined);
    if (!uid) {
      try {
        const chatDoc = await db.doc(`chats/${chatId}`).get();
        uid = (chatDoc.data()?.participants ?? [])[0] as string | undefined;
      } catch (e) {
        logger.warn("Can't infer uid from chat participants", e);
      }
    }

    // 4) Контекст из Firestore добавляем как 'user'-сообщение
    try {
      const ctx = await buildFirebaseContext(db, uid, msg.text);
      if (ctx) history.push({role: "user", parts: [{text: ctx}]});
    } catch (e) {
      logger.warn("Context build error", e);
    }

    // 5) Системная инструкция
    const systemInstruction = [
      "Ты — футбольный тренер-бот.",
      "Анализируй вопросы и контекст из сообщения 'Данные из БД'.",
      "Давай краткие практические рекомендации.",
      "Если данных мало — вежливо уточни.",
      "Не говори, что у тебя нет доступа к БД — контекст уже дан.",
      "Отвечай на том же языке, что и последний вопрос.",
    ].join(" ");

    const genAI = new GoogleGenerativeAI(
      process.env.GEMINI_API_KEY as string,
    );
    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash",
      systemInstruction,
    });

    // 6) Диалог
    let reply =
      "Сорян, сейчас не смог ответить. " +
      "Попробуй ещё раз или перефразируй вопрос.";
    try {
      const chat = model.startChat({
        history,
        generationConfig: {maxOutputTokens: 512, temperature: 0.7},
      });
      const result = await chat.sendMessage(msg.text);
      reply = result.response.text() || reply;
    } catch (e) {
      logger.error("gemini error", e);
    }

    // 7) Записываем ответ
    await db.collection(`chats/${chatId}/messages`).add({
      role: "assistant",
      text: reply,
      senderId: "coach-bot",
      createdAt: FieldValue.serverTimestamp(),
    });
  },
);
