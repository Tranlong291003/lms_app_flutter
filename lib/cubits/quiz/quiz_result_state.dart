part of 'quiz_cubit.dart';

abstract class QuizResultState {}

class QuizResultInitial extends QuizResultState {}

class QuizResultLoading extends QuizResultState {}

class QuizResultLoaded extends QuizResultState {
  final QuizResultModel result;
  QuizResultLoaded(this.result);
}

class QuizResultError extends QuizResultState {
  final String message;
  QuizResultError(this.message);
}
