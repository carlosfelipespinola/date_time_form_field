library date_time_picker_form_field;

import 'package:flutter/material.dart';

String _simpleDateFormatter(DateTime d) => d.toString(); 

class DatePickerFormField extends FormField<DateTime> {

  DatePickerFormField({
    Key? key,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime initialDate,
    String Function(DateTime?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool enabled = true,
    required String label,
    void Function(DateTime?)? onSaved,
    void Function(DateTime?)? onChanged,
    String Function(DateTime) dateFormatter = _simpleDateFormatter
  }) : assert(initialDate != null), super(
    key: key,
    initialValue: initialDate,
    validator: validator,
    autovalidateMode: autovalidateMode,
    enabled: enabled,
    onSaved: onSaved,
    builder: (state) {
      final inputDecoration = Theme.of(state.context).inputDecorationTheme;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 12,
        ),
        child: InkWell(
          borderRadius: inputDecoration.border is OutlineInputBorder ? 
            (inputDecoration.border as OutlineInputBorder).borderRadius : null,
          onTap: enabled ? () async {
            final date = await showDatePicker(
              context: state.context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate
            );
            if (date == null) {
              return;
            }
            final time = await showTimePicker(
              context: state.context,
              initialTime: TimeOfDay.fromDateTime(initialDate)
            );
            if (time == null) {
              return;
            }
            final newValue = DateTime(date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);
            if (newValue != state.value) {
              state.didChange(newValue);
              if (onChanged != null) {
                onChanged(newValue);
              }
            }
          } : null,
          child: InputDecorator(
            decoration: state.hasError ?
              InputDecoration(errorText: state.errorText, labelText: label).applyDefaults(inputDecoration) :
              InputDecoration(labelText: label).applyDefaults(inputDecoration),
            isEmpty: false,
            child: Text(dateFormatter(state.value!), style: Theme.of(state.context).textTheme.bodyText1,)
          ),
        )
      );
    }
  );
}
