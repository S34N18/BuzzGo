import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _users = [];
  List<PaymentModel> _userPayments = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get users => _users;
  List<PaymentModel> get userPayments => _userPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all users (admin function)
  Future<void> loadUsers() async {
    try {
      _setLoading(true);
      _clearError();

      // This would require a custom Firestore query or Cloud Function
      // For now, we'll leave it as a placeholder
      _users = [];
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load user payments
  Future<void> loadUserPayments(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _userPayments = await _firestoreService.getUserPayments(userId);
      _userPayments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _setError('Failed to load payments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _firestoreService.getUser(userId);
    } catch (e) {
      _setError('Failed to get user: ${e.toString()}');
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateUser(user);
      
      // Update in local list if exists
      int index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add payment
  Future<bool> addPayment(PaymentModel payment) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.createPayment(payment);
      
      // Add to local list
      _userPayments.insert(0, payment);
      
      return true;
    } catch (e) {
      _setError('Failed to add payment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update payment
  Future<bool> updatePayment(PaymentModel payment) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updatePayment(payment);
      
      // Update in local list
      int index = _userPayments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _userPayments[index] = payment;
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update payment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get payment by transaction ID
  PaymentModel? getPaymentByTransactionId(String transactionId) {
    try {
      return _userPayments.firstWhere((p) => p.transactionId == transactionId);
    } catch (e) {
      return null;
    }
  }

  // Get payments by status
  List<PaymentModel> getPaymentsByStatus(PaymentStatus status) {
    return _userPayments.where((p) => p.status == status).toList();
  }

  // Get total amount paid by user
  double getTotalAmountPaid(String userId) {
    return _userPayments
        .where((p) => p.userId == userId && p.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get payment statistics
  Map<String, dynamic> getPaymentStatistics() {
    int totalPayments = _userPayments.length;
    int completedPayments = _userPayments.where((p) => p.status == PaymentStatus.completed).length;
    int failedPayments = _userPayments.where((p) => p.status == PaymentStatus.failed).length;
    int pendingPayments = _userPayments.where((p) => p.status == PaymentStatus.pending).length;
    
    double totalAmount = _userPayments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
    
    double averageAmount = completedPayments > 0 ? totalAmount / completedPayments : 0.0;

    return {
      'totalPayments': totalPayments,
      'completedPayments': completedPayments,
      'failedPayments': failedPayments,
      'pendingPayments': pendingPayments,
      'totalAmount': totalAmount,
      'averageAmount': averageAmount,
      'successRate': totalPayments > 0 ? (completedPayments / totalPayments) * 100 : 0.0,
    };
  }

  // Search users (admin function)
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    return _users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
             user.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter users by admin status
  List<UserModel> filterUsersByAdminStatus(bool isAdmin) {
    return _users.where((user) => user.isAdmin == isAdmin).toList();
  }

  // Get recent payments
  List<PaymentModel> getRecentPayments({int limit = 10}) {
    List<PaymentModel> sortedPayments = List.from(_userPayments);
    sortedPayments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPayments.take(limit).toList();
  }

  // Get payments by date range
  List<PaymentModel> getPaymentsByDateRange(DateTime startDate, DateTime endDate) {
    return _userPayments.where((payment) {
      return payment.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
             payment.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get monthly payment summary
  Map<String, double> getMonthlyPaymentSummary() {
    Map<String, double> monthlySummary = {};
    
    for (PaymentModel payment in _userPayments) {
      if (payment.status == PaymentStatus.completed) {
        String monthKey = '${payment.createdAt.year}-${payment.createdAt.month.toString().padLeft(2, '0')}';
        monthlySummary[monthKey] = (monthlySummary[monthKey] ?? 0.0) + payment.amount;
      }
    }
    
    return monthlySummary;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Clear all data
  void clearData() {
    _users.clear();
    _userPayments.clear();
    _clearError();
    notifyListeners();
  }
}