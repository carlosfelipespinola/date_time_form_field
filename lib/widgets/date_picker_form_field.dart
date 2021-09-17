import 'package:flutter/material.dart';

String _simpleDateFormatter(DateTime d) => d.toString();

class DatePickerFormField extends FormField<DateTime> {
  final InputDecoration? decoration;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final String Function(DateTime?)? validator;
  final AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final String Function(DateTime) dateFormatter = _simpleDateFormatter;
  final Future<DateTime?> Function()? openDatePicker;
  final void Function(DateTime?)? onChanged;
  final void Function()? onBeforeOpenDateTimePicker;
  final void Function()? onAfterCloseDateTimePicker;


  DatePickerFormField({
    Key? key,
    this.decoration,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool? enabled = true,
    void Function(DateTime?)? onSaved,
    this.onChanged,
    String Function(DateTime) dateFormatter = _simpleDateFormatter,
    this.openDatePicker,
    this.onBeforeOpenDateTimePicker,
    this.onAfterCloseDateTimePicker
  }) : super(
    key: key,
    initialValue: initialDate,
    validator: validator,
    autovalidateMode: autovalidateMode,
    enabled: enabled ?? decoration?.enabled ?? true,
    onSaved: onSaved,
    builder: (s) {
      final _DatePickerFormFieldState state = s as _DatePickerFormFieldState;
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
          child: Text(dateFormatter(state.value!), style: Theme.of(state.context).textTheme.subtitle1,)
        ),
      );
    }
  );

  @override
  _DatePickerFormFieldState createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends FormFieldState<DateTime> {

  bool isFocused = false;

  onTap () async {
    final datePickedWidget = widget as DatePickerFormField;
    datePickedWidget.onBeforeOpenDateTimePicker?.call();
    setState(() { isFocused = true; });
    final date = await datePickedWidget.openDatePicker?.call() ?? await showDatePicker(
      context: context,
      initialDate: datePickedWidget.initialDate,
      firstDate: datePickedWidget.firstDate,
      lastDate: datePickedWidget.lastDate,
    );
    if (date == null) {
      setState(() { isFocused = false; });
      datePickedWidget.onAfterCloseDateTimePicker?.call();
      return;
    }
    if (date.toIso8601String() != value?.toIso8601String()) {
      didChange(date);
      datePickedWidget.onChanged?.call(date);
    }
    setState(() { isFocused = false; });
    datePickedWidget.onAfterCloseDateTimePicker?.call();
  }
}
