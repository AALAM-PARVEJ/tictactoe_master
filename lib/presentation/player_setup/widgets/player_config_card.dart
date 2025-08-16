import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlayerConfigCard extends StatefulWidget {
  final String playerNumber;
  final String initialName;
  final String initialSymbol;
  final Color cardColor;
  final Function(String) onNameChanged;
  final Function(String) onSymbolChanged;
  final String otherPlayerSymbol;

  const PlayerConfigCard({
    Key? key,
    required this.playerNumber,
    required this.initialName,
    required this.initialSymbol,
    required this.cardColor,
    required this.onNameChanged,
    required this.onSymbolChanged,
    required this.otherPlayerSymbol,
  }) : super(key: key);

  @override
  State<PlayerConfigCard> createState() => _PlayerConfigCardState();
}

class _PlayerConfigCardState extends State<PlayerConfigCard> {
  late TextEditingController _nameController;
  late String _selectedSymbol;
  final int _maxNameLength = 15;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedSymbol = widget.initialSymbol;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSymbolTap(String symbol) {
    if (symbol != widget.otherPlayerSymbol) {
      setState(() {
        _selectedSymbol = symbol;
      });
      widget.onSymbolChanged(symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.cardColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header
          Row(
            children: [
              Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: widget.cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.playerNumber,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: widget.cardColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Player ${widget.playerNumber}',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: widget.cardColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Name Input Section
          Text(
            'Player Name',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _nameController,
            maxLength: _maxNameLength,
            onChanged: (value) {
              widget.onNameChanged(value.trim().isEmpty
                  ? 'Player ${widget.playerNumber}'
                  : value);
            },
            onTap: () {
              if (_nameController.text == 'Player ${widget.playerNumber}') {
                _nameController.clear();
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter player name',
              counterText: '${_nameController.text.length}/$_maxNameLength',
              counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: widget.cardColor,
                  size: 20,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.cardColor, width: 2),
              ),
            ),
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 2.h),

          // Symbol Selection Section
          Text(
            'Game Symbol',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildSymbolButton('X'),
              SizedBox(width: 4.w),
              _buildSymbolButton('O'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolButton(String symbol) {
    final bool isSelected = _selectedSymbol == symbol;
    final bool isDisabled = widget.otherPlayerSymbol == symbol;

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : () => _onSymbolTap(symbol),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 6.h,
          decoration: BoxDecoration(
            color: isSelected
                ? widget.cardColor
                : isDisabled
                    ? AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? widget.cardColor
                  : isDisabled
                      ? AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3)
                      : widget.cardColor.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              symbol,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDisabled
                        ? AppTheme.lightTheme.colorScheme.outline
                        : widget.cardColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
