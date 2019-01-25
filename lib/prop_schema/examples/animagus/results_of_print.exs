# credo:disable-for-this-file
property("valid changeset") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing date_format") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing email") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing event_date") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("invalid changeset - missing event_name") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(changeset.valid?()) do
         Logger.error("Test will fail because: No errors")
       end

       refute(changeset.valid?())
     end).(changeset)
  end
end

property("invalid changeset - missing expected_columns") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(changeset.valid?()) do
         Logger.error("Test will fail because: No errors")
       end

       refute(changeset.valid?())
     end).(changeset)
  end
end

property("invalid changeset - missing external_location_id") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(changeset.valid?()) do
         Logger.error("Test will fail because: No errors")
       end

       refute(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing file_regex") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing integration_name") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing name_regex") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing parser") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("invalid changeset - missing primary_name") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(changeset.valid?()) do
         Logger.error("Test will fail because: No errors")
       end

       refute(changeset.valid?())
     end).(changeset)
  end
end

property("invalid changeset - missing primary_phone") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(changeset.valid?()) do
         Logger.error("Test will fail because: No errors")
       end

       refute(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing secondary_name") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing secondary_phone") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"tertiary_phone", one_of([integer(61..70), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end

property("valid changeset - missing tertiary_phone") do
  check(
    all(
      map <-
        StreamData.fixed_map([
          {"date_format",
           StreamData.one_of([StreamData.string(:ascii), StreamData.constant(nil)])},
          {"email", one_of([integer(71..80), constant(nil)])},
          {"event_date", one_of([integer(11..20), constant(nil)])},
          {"event_name", StreamData.string(:alphanumeric, min_length: 1)},
          {"expected_columns", integer(81..100)},
          {"external_location_id", integer(1..10)},
          {"file_regex", one_of([string([33..126], min_length: 1), constant(".*.[cC][sS][vV]")])},
          {"integration_name",
           one_of([string(:alphanumeric, min_length: 1), constant("external")])},
          {"name_regex",
           one_of([constant("(?<last>.*), *(?<first>.*)"), constant("(?<first>.*) +(?<last>.*)")])},
          {"parser", one_of([string(:alphanumeric, min_length: 1), constant("CSV")])},
          {"primary_name", integer(21..30)},
          {"primary_phone", integer(41..50)},
          {"secondary_name", one_of([integer(31..40), constant(nil)])},
          {"secondary_phone", one_of([integer(51..60), constant(nil)])}
        ])
    )
  ) do
    changeset = Animagus.CSVMapping.changeset(struct(Animagus.CSVMapping), map)

    (fn changeset ->
       if(not changeset.valid?()) do
         Logger.error("Test will fail because: #{inspect(changeset.errors())}")
       end

       assert(changeset.valid?())
     end).(changeset)
  end
end
