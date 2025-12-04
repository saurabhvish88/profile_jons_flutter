class FormConfig {
  final String id;
  final int formId;
  final String tableName;
  final String menuID;
  final int status;
  final bool isRequiredAttachment;
  final List<FormButton> buttons;
  final List<FormField> fields;
  final List<ChildSection> child;

  FormConfig({
    required this.id,
    required this.formId,
    required this.tableName,
    required this.menuID,
    required this.status,
    required this.isRequiredAttachment,
    required this.buttons,
    required this.fields,
    required this.child,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      id: json['_id'] ?? '',
      formId: json['id'] ?? 0,
      tableName: json['tableName'] ?? '',
      menuID: json['menuID'] ?? '',
      status: json['status'] ?? 0,
      isRequiredAttachment: json['isRequiredAttachment'] ?? false,
      buttons: (json['buttons'] as List<dynamic>?)
              ?.map((b) => FormButton.fromJson(b))
              .toList() ??
          [],
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => FormField.fromJson(f))
              .toList() ??
          [],
      child: (json['child'] as List<dynamic>?)
              ?.map((c) => ChildSection.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class FormButton {
  final String name;
  final String functionOnClick;
  final String type;
  final String? iconName;

  FormButton({
    required this.name,
    required this.functionOnClick,
    required this.type,
    this.iconName,
  });

  factory FormButton.fromJson(Map<String, dynamic> json) {
    return FormButton(
      name: json['name'] ?? '',
      functionOnClick: json['functionOnClick'] ?? '',
      type: json['type'] ?? '',
      iconName: json['iconName'],
    );
  }
}

class FormField {
  final String fieldname;
  final String yourlabel;
  final String controlname;
  final bool isControlShow;
  final bool? isRequired;
  final bool? isEditable;
  final String? sectionHeader;
  final int? sectionOrder;
  final int? ordering;
  final String? type;
  final int? size;
  final String? referenceTable;
  final String? referenceColumn;
  final String? dropdownFilter;
  final List<dynamic>? data;
  final dynamic controlDefaultValue;

  FormField({
    required this.fieldname,
    required this.yourlabel,
    required this.controlname,
    required this.isControlShow,
    this.isRequired,
    this.isEditable,
    this.sectionHeader,
    this.sectionOrder,
    this.ordering,
    this.type,
    this.size,
    this.referenceTable,
    this.referenceColumn,
    this.dropdownFilter,
    this.data,
    this.controlDefaultValue,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      fieldname: json['fieldname'] ?? '',
      yourlabel: json['yourlabel'] ?? '',
      controlname: json['controlname'] ?? '',
      isControlShow: json['isControlShow'] ?? true,
      isRequired: json['isRequired'],
      isEditable: json['isEditable'],
      sectionHeader: json['sectionHeader'],
      sectionOrder: json['sectionOrder'],
      ordering: json['ordering'],
      type: json['type'],
      size: json['size'],
      referenceTable: json['referenceTable'],
      referenceColumn: json['referenceColumn'],
      dropdownFilter: json['dropdownFilter'],
      data: json['data'],
      controlDefaultValue: json['controlDefaultValue'],
    );
  }
}

class ChildSection {
  final String tableName;
  final bool isChildCopy;
  final String childHeading;
  final int childOrder;
  final List<FormField> fields;

  ChildSection({
    required this.tableName,
    required this.isChildCopy,
    required this.childHeading,
    required this.childOrder,
    required this.fields,
  });

  factory ChildSection.fromJson(Map<String, dynamic> json) {
    return ChildSection(
      tableName: json['tableName'] ?? '',
      isChildCopy: json['isChildCopy'] ?? false,
      childHeading: json['childHeading'] ?? '',
      childOrder: json['childOrder'] ?? 0,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => FormField.fromJson(f))
              .toList() ??
          [],
    );
  }
}

