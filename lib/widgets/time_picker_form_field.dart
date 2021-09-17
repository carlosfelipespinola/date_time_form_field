import 'package:flutter/material.dart';

String _simpletimeFormatter(TimeOfDay time) => "${time.hour < 10 ? 0 : ''}${time.hour}:${time.minute < 10 ? 0 : ''}${time.minute}";

class TimePickerFormField extends FormField<TimeOfDay> {
  final InputDecoration? decoration;
  final TimeOfDay initialTime;
  final String Function(TimeOfDay?)? validator;
  final AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final String Function(TimeOfDay) timeFormatter = _simpletimeFormatter;
  final Future<TimeOfDay?> Function()? openTimePicker;
  final void Function(TimeOfDay?)? onChanged;
  final void Function()? onBeforeOpenTimePicker;
  final void Function()? onAfterCloseTimePicker;


  TimePickerFormField({
    Key? key,
    this.decoration,
    required this.initialTime,
    this.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool? enabled = true,
    void Function(TimeOfDay?)? onSaved,
    this.onChanged,
    String Function(TimeOfDay) timeFormatter = _simpletimeFormatter,
    this.openTimePicker,
    this.onBeforeOpenTimePicker,
    this.onAfterCloseTimePicker
  }) : super(
    key: key,
    initialValue: initialTime,
    validator: validator,
    autovalidateMode: autovalidateMode,
    enabled: enabled ?? decoration?.enabled ?? true,
    onSaved: onSaved,
    builder: (s) {
      final _TimePickerFormFieldState state = s as _TimePickerFormFieldState;
      final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(state.context).inputDecorationTheme);
      return InkWell(
        borderRadius: effectiveDecoration.border is OutlineInputBorder ? 
          (effectiveDecoration.border as OutlineInputBorder).borderRadius : null,
        onTap: state.widget.enabled ? state.onTap : null,
        child: InputDecorator(
          decoration: effectiveDecoration.copyWith(errorText: state.errorText),
          isEmpty: false,
          isFocused: state.isFocused,
          child: Text(timeFormatter(state.value!), style: Theme.of(state.context).textTheme.subtitle1,)
        ),
      );
    }
  );

  @override
  _TimePickerFormFieldState createState() => _TimePickerFormFieldState();
}

class _TimePickerFormFieldState extends FormFieldState<TimeOfDay> {

  bool isFocused = false;

  onTap () async {
    final timePickerWidget = widget as TimePickerFormField;
    timePickerWidget.onBeforeOpenTimePicker?.call();
    setState(() { isFocused = true; });
    final time = await timePickerWidget.openTimePicker?.call() ?? await showTimePicker(
      context: context,
      initialTime: timePickerWidget.initialTime
    );
    if (time == null) {
      setState(() { isFocused = false; });
      timePickerWidget.onAfterCloseTimePicker?.call();
      return;
    }
    if (time != value) {
      didChange(time);
      timePickerWidget.onChanged?.call(time);
    }
    setState(() { isFocused = false; });
    timePickerWidget.onAfterCloseTimePicker?.call();
  }
}
