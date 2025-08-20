import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class TableActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData? icon;

  const TableActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
  });

  @override
  State<TableActionButton> createState() => _TableActionButtonState();
}

class _TableActionButtonState extends State<TableActionButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isHovered
                      ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StyledDataTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;

  const StyledDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 64,
          horizontalMargin: 24,
          columnSpacing: 32,
          headingRowColor: MaterialStateProperty.all(
          const Color(0xFFF8FAFC),
          ),
          headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
          fontFamily: 'Poppins',
          fontSize: 14,
          letterSpacing: 0.5,
          ),
          dataTextStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
          fontFamily: 'Poppins',
          fontSize: 13,
          ),
          columns: columns
          .map((col) => DataColumn(
          label: Text(col),
          ))
              .toList(),
          rows: rows
              .asMap()
              .entries
              .map((entry) => DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
          if (entry.key % 2 == 0) {
          return Colors.grey.shade50;
          }
          return null;
          },
          ),
          cells: entry.value.cells,
          ))
              .toList(),
          ),
          ));
        },
      ),
    );
  }
}