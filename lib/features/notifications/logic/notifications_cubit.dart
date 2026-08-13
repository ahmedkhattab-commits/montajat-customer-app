import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/features/notifications/data/models/app_notification_model.dart';
import 'package:montajat_customer_app/features/notifications/data/repositories/notifications_repository.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.loading = false,
    this.items = const [],
    this.unreadCount = 0,
    this.mutatingId,
    this.error,
  });
  final bool loading;
  final List<AppNotificationModel> items;
  final int unreadCount;
  final Object? mutatingId;
  final String? error;

  NotificationsState copyWith({
    bool? loading,
    List<AppNotificationModel>? items,
    int? unreadCount,
    Object? mutatingId,
    bool clearMutating = false,
    String? error,
    bool clearError = false,
  }) => NotificationsState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    mutatingId: clearMutating ? null : mutatingId ?? this.mutatingId,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [loading, items, unreadCount, mutatingId, error];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());
  final NotificationsRepository _repository;

  Future<void> load() async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final values = await Future.wait([
        _repository.getNotifications(),
        _repository.getUnreadCount(),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          items: values[0] as List<AppNotificationModel>,
          unreadCount: values[1] as int,
        ),
      );
    } on NotificationsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(loading: false, error: error.messageKey));
      }
    }
  }

  Future<void> markAsRead(AppNotificationModel item) async {
    if (item.isRead || state.mutatingId != null) return;
    emit(state.copyWith(mutatingId: item.id, clearError: true));
    try {
      await _repository.markAsRead(item.id);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: state.items
              .map(
                (value) =>
                    value.id == item.id ? value.copyWith(isRead: true) : value,
              )
              .toList(growable: false),
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          clearMutating: true,
        ),
      );
    } on NotificationsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(clearMutating: true, error: error.messageKey));
      }
    }
  }

  Future<void> readAll() async {
    if (state.mutatingId != null || state.unreadCount == 0) return;
    emit(state.copyWith(mutatingId: 'all', clearError: true));
    try {
      await _repository.readAll();
      if (isClosed) return;
      emit(
        state.copyWith(
          items: state.items
              .map((item) => item.copyWith(isRead: true))
              .toList(),
          unreadCount: 0,
          clearMutating: true,
        ),
      );
    } on NotificationsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(clearMutating: true, error: error.messageKey));
      }
    }
  }

  Future<bool> delete(AppNotificationModel item) async {
    if (state.mutatingId != null) return false;
    emit(state.copyWith(mutatingId: item.id, clearError: true));
    try {
      await _repository.delete(item.id);
      if (isClosed) return false;
      emit(
        state.copyWith(
          items: state.items.where((value) => value.id != item.id).toList(),
          unreadCount: !item.isRead && state.unreadCount > 0
              ? state.unreadCount - 1
              : state.unreadCount,
          clearMutating: true,
        ),
      );
      return true;
    } on NotificationsException catch (error) {
      if (!isClosed) {
        emit(state.copyWith(clearMutating: true, error: error.messageKey));
      }
      return false;
    }
  }
}
