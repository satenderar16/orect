enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  none,
  unknown,
}

class InternetState {
  final bool hasInternet;
  final ConnectionType connectionType;

  const InternetState({
    required this.hasInternet,
    required this.connectionType,
  });

  InternetState copyWith({
    bool? hasInternet,
    ConnectionType? connectionType,
  }) {
    return InternetState(
      hasInternet: hasInternet ?? this.hasInternet,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  @override
  String toString() =>
      'InternetState(hasInternet: $hasInternet, connectionType: $connectionType)';
}
