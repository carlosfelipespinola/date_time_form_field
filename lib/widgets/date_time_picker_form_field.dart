import 'package:flutter/material.dart';

String _simpleDateFormatter(DateTime d) => d.toString();

class DateTimePickerFormField extends FormField<DateTime> {
  final InputDecoration? decoration;
  final DateTime firstDateTime;
  final DateTime lastDateTime;
  final DateTime initialDateTime;
  final String Function(DateTime?)? validator;
  final AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final String Function(DateTime) dateFormatter = _simpleDateFormatter;
  final Future<DateTime?> Function()? openDatePicker;
  final Future<TimeOfDay?> Function()? openTimePicker;
  final void Function(DateTime?)? onChanged;
  final void Function()? onBeforeOpenDateTimePicker;
  final void Function()? onAfterCloseDateTimePicker;


  DateTimePickerFormField({
    Key? key,
    this.decoration,
    required this.firstDateTime,
    required this.lastDateTime,
    required this.initialDateTime,
    this.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool? enabled = true,
    void Function(DateTime?)? onSaved,
    this.onChanged,
    String Function(DateTime) dateFormatter = _simpleDateFormatter,
    this.openDatePicker,
    this.openTimePicker,
    this.onBeforeOpenDateTimePicker,
    this.onAfterCloseDateTimePicker
  }) : super(
    key: key,
    initialValue: initialDateTime,
    validator: validator,
    autovalidateMode: autovalidateMode,
    enabled: enabled ?? decoration?.enabled ?? true,
    onSaved: onSaved,
    builder: (s) {
      final _DateTimePickerFormFieldState state = s as _DateTimePickerFormFieldState;
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
  _DateTimePickerFormFieldState createState() => _DateTimePickerFormFieldState();
}

class _DateTimePickerFormFieldState extends FormFieldState<DateTime> {

  bool isFocused = false;

  onTap () async {
    final datePickedWidget = widget as DateTimePickerFormField;
    datePickedWidget.onBeforeOpenDateTimePicker?.call();
    setState(() { isFocused = true; });
    final date = await datePickedWidget.openDatePicker?.call() ?? await showDatePicker(
      context: context,
      initialDate: datePickedWidget.initialDateTime,
      firstDate: datePickedWidget.firstDateTime,
      lastDate: datePickedWidget.lastDateTime,
    );
    if (date == null) {
      setState(() { isFocused = false; });
      datePickedWidget.onAfterCloseDateTimePicker?.call();
      return;
    }
    final time = await datePickedWidget.openTimePicker?.call() ?? await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(datePickedWidget.initialDateTime)
    );
    if (time == null) {
      setState(() { isFocused = false; });
      datePickedWidget.onAfterCloseDateTimePicker?.call();
      return;
    }
    final newValue = DateTime(date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);
    if (newValue != value) {
      didChange(newValue);
      datePickedWidget.onChanged?.call(newValue);
    }
    setState(() { isFocused = false; });
    datePickedWidget.onAfterCloseDateTimePicker?.call();
  }
}
