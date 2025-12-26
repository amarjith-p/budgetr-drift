import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/investment_model.dart';

class InvestmentListItem extends StatelessWidget {
  final InvestmentRecord item;
  final NumberFormat currencyFormat;
  final NumberFormat preciseFormat;
  final VoidCallback onOptions; // Fix: Use callback instead of internal menu

  const InvestmentListItem({
    super.key,
    required this.item,
    required this.currencyFormat,
    required this.preciseFormat,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = item.totalReturn >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tag(_getTypeName(item.type)),
                        const SizedBox(width: 8),
                        Text(
                          item.bucket,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Option Button
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                  size: 20,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: onOptions,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                preciseFormat.format(item.currentValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "${isProfit ? '+' : ''}${item.returnPercentage.toStringAsFixed(1)}% (${currencyFormat.format(item.totalReturn)})",
                style: TextStyle(
                  color: isProfit ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailCol(
                "Qty",
                item.quantity.toStringAsFixed(
                  item.type == InvestmentType.stock ? 0 : 2,
                ),
              ),
              _detailCol("Avg", currencyFormat.format(item.averagePrice)),
              _detailCol("LTP", currencyFormat.format(item.currentPrice)),
              _detailCol("Inv", currencyFormat.format(item.totalInvested)),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeName(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return "STOCK";
      case InvestmentType.mutualFund:
        return "MF";
      case InvestmentType.other:
        return "OTHER";
    }
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    ),
  );

  Widget _detailCol(String label, String val) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
      ),
      const SizedBox(height: 2),
      Text(
        val,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
