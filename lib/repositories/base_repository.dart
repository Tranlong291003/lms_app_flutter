import 'package:flutter/foundation.dart';

/// Lớp cơ sở cho các repository, sử dụng generic cho Service
abstract class BaseRepository<TService> {
  @protected
  final TService service;

  const BaseRepository(this.service);
}
