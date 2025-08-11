// lib/presentation/widgets/profile/edit_profile_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';
import 'package:footlog/domain/home/enums/positions.dart';

/// Содержимое шторки редактирования профиля.
/// Важно: рамка/отступы/ширина делаются во внешнем файле (showEditProfileBottomSheet).
class EditProfileBottomSheet extends StatefulWidget {
  final PlayerProfile initial;
  const EditProfileBottomSheet({super.key, required this.initial});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late final TextEditingController _name;
  late Position _primary;
  late Set<Position> _positions;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _primary = widget.initial.primaryPosition;
    _positions = widget.initial.positions.toSet()..add(widget.initial.primaryPosition);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    _FakeTab(text: 'Имя', selected: true),
                    SizedBox(width: 16),
                    _FakeTab(text: 'Имя Фамилия', selected: false),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, null),
            tooltip: 'Закрыть',
          ),
        ],
      ),
    );
  }

  Widget _group(String t) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Center(
      child: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );

  Widget _row(Position p, String label) {
    final isPrimary = p == _primary;
    final inList = _positions.contains(p);

    return InkWell(
      onTap: () => setState(() {
        _primary = p;
        _positions.add(p);
        HapticFeedback.selectionClick();
      }),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: _PrimaryDot(selected: isPrimary),
        title: Text(label),
        trailing: Checkbox(
          value: inList,
          onChanged: (v) => setState(() {
            if (v == true) {
              _positions.add(p);
            } else {
              if (p == _primary) return; // primary нельзя убрать
              _positions.remove(p);
            }
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _saveButton() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final name = _name.text.trim().isEmpty ? widget.initial.name : _name.text.trim();
          final fixed = Set<Position>.from(_positions)..add(_primary);
          Navigator.pop(
            context,
            PlayerProfile(
              name: name,
              primaryPosition: _primary,
              positions: fixed.toList(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Готово'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Имя',
              isDense: true,
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        const Divider(height: 16),
        // Скроллируемая часть
        Flexible(
          fit: FlexFit.loose,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            children: [
              _group('Вратарь'),
              _row(Position.GK, 'GK — Вратарь'),

              _group('Защитники'),
              _row(Position.CB, 'CB — Центральный защитник'),
              _row(Position.LB, 'LB — Левый защитник'),
              _row(Position.RB, 'RB — Правый защитник'),

              _group('Полузащитники'),
              _row(Position.CDM, 'CDM — Опорный полузащитник'),
              _row(Position.CM, 'CM — Центральный полузащитник'),
              _row(Position.CAM, 'CAM — Атакующий полузащитник'),
              _row(Position.RM, 'RM — Правый полузащитник'),
              _row(Position.LM, 'LM — Левый полузащитник'),

              _group('Вингеры'),
              _row(Position.RW, 'RW — Правый вингер'),
              _row(Position.LW, 'LW — Левый вингер'),

              _group('Нападающие'),
              _row(Position.ST, 'ST — Страйкер'),
            ],
          ),
        ),
        _saveButton(),
      ],
    );
  }
}

/// ——— мелкие виджеты (для заголовка и индикатора primary)
class _FakeTab extends StatelessWidget {
  final String text;
  final bool selected;
  const _FakeTab({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.black54;
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: color,
      ),
    );
  }
}

class _PrimaryDot extends StatelessWidget {
  final bool selected;
  const _PrimaryDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.black26,
          width: 2,
        ),
        // Flutter 3.22+: withValues вместо withOpacity
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
    );
  }
}
