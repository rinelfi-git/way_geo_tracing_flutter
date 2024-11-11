class SettingSchema {
  static const String TABLE = 'setting';
  static const String DEVICE_NAME = 'device_name';
  static const String SERVER = 'server';
  static const String UUID = 'uuid';
  static const String AUTOSYNC = 'autosync';
  static const List<String> VALUES = [DEVICE_NAME, SERVER, UUID, AUTOSYNC];
}

class Setting {
  final String? deviceName;
  final String? server;
  final String? uuid;
  final bool? autoSync;

  const Setting({
    this.deviceName,
    this.server,
    this.uuid,
    this.autoSync,
  });

  Map<String, dynamic> toMap() {
    final map = {
      SettingSchema.DEVICE_NAME: deviceName ?? '',
      SettingSchema.SERVER: server ?? '',
      SettingSchema.UUID: uuid ?? '',
      SettingSchema.AUTOSYNC: (autoSync ?? false) ? 1 : 0
    };
    return map;
  }

  Setting copy({String? deviceName, String? server, String? uuid, bool? autoSync}) {
    return Setting(
      deviceName: deviceName ?? this.deviceName,
      server: server ?? this.server,
      uuid: uuid ?? this.uuid,
      autoSync: autoSync ?? this.autoSync,
    );
  }

  static Setting fromMap(Map<String, Object?> map) {
    return Setting(
      deviceName: map[SettingSchema.DEVICE_NAME] as String,
      server: map[SettingSchema.SERVER] as String,
      uuid: map[SettingSchema.UUID] as String,
      autoSync: map[SettingSchema.AUTOSYNC] as int == 1,
    );
  }
}
