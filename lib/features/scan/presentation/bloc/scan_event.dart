part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

class ProcessImageEvent extends ScanEvent {
  final String imagePath;

  const ProcessImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
