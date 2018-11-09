syslog_settings {'default':
  console                => 2,
  monitor                => 5,
  source_interface       => ['unset'],
  time_stamp_units       => 'milliseconds',
  logfile_name           => 'testlogfile',
  logfile_severity_level => 3,
  logfile_size           => -1,
}
