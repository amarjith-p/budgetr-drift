import 'dart:math';

class XirrCalculator {
  static const double tol = 0.0000001; // Tolerance for accuracy
  static const int maxIter = 100; // Prevent infinite loops

  /// Calculates XIRR.
  /// [transactions]: List of cash flows (Date, Amount).
  /// IMPORTANT:
  /// - Investments (Money Out) must be NEGATIVE.
  /// - Withdrawals/CurrentValue (Money In) must be POSITIVE.
  static double? calculate(List<XirrTransaction> transactions) {
    if (transactions.length < 2) return null;

    // Check if we have at least one positive and one negative cash flow
    bool hasPositive = transactions.any((t) => t.amount > 0);
    bool hasNegative = transactions.any((t) => t.amount < 0);
    if (!hasPositive || !hasNegative) return null;

    // Sort by date
    transactions.sort((a, b) => a.date.compareTo(b.date));

    final DateTime startDate = transactions.first.date;
    double xirr = 0.1; // Initial guess (10%)

    for (int i = 0; i < maxIter; i++) {
      double fValue = 0.0;
      double fDerivative = 0.0;

      for (var t in transactions) {
        final double days = t.date.difference(startDate).inDays.toDouble();
        final double years = days / 365.0;

        // Avoid division by zero if rate is -100%
        if (xirr <= -1.0) xirr = -0.99;

        final double factor = pow(1.0 + xirr, years).toDouble();

        fValue += t.amount / factor;
        fDerivative -= (t.amount * years) / (factor * (1.0 + xirr));
      }

      if (fValue.abs() < tol) {
        return xirr * 100; // Return as percentage
      }

      if (fDerivative == 0) return null; // Failed to converge

      double newXirr = xirr - (fValue / fDerivative);

      // Limit huge jumps
      if (newXirr.abs() > 1000) return null;

      xirr = newXirr;
    }

    return null; // Did not converge
  }

  /// Calculates the Maximum Drawdown (Peak to Trough drop)
  static double calculateMaxDrawdown(List<double> historicalValues) {
    if (historicalValues.isEmpty) return 0.0;

    double peak = historicalValues[0];
    double maxDrawdown = 0.0;

    for (double value in historicalValues) {
      if (value > peak) {
        peak = value; // New high water mark
      }
      
      double drawdown = (peak - value) / peak;
      if (drawdown > maxDrawdown) {
        maxDrawdown = drawdown;
      }
    }

    return maxDrawdown * 100; // Return as a percentage
  }
}

class XirrTransaction {
  final DateTime date;
  final double amount;

  XirrTransaction(this.date, this.amount);
}