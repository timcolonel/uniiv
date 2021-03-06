namespace :db do
  def command_args(config)
    abort 'Missing database name' if config['database'].blank?

    args = ''
    args << "-u #{config['username']} " if config['username'].present?
    args << "-p\"#{config['password']}\" " if config['password'].present?
    args << config['database']
  end

  task :sync_local, :database do |t, args|
    args.with_defaults(:database => 'development')
    config = Rails.application.config.database_configuration

    abort 'Missing Main developement db config' if config['development_main'].blank?

    dev = config[args[:database]]
    live = config['development_main']

    #Clean the database
    if args[:database] == 'development'
      Rake.application.invoke_task('db:drop')
      Rake.application.invoke_task('db:create')
      Rake.application.invoke_task('db:migrate')
      Rake.application.invoke_task('db:test:prepare')
    end

    abort 'Dev db is not mysql' unless dev['adapter'] =~ /mysql/
    abort 'Live db is not mysql' unless live['adapter'] =~ /mysql/
    abort 'Missing ssh host' if live['host'].blank?

    cmd = 'ssh -C '
    cmd << "#{live['ssh_user']}@" if live['ssh_user'].present?
    cmd << "#{live['host']} mysqldump #{command_args(live)} | "
    cmd << "mysql #{command_args(dev)}"

    system `#{cmd}`
    system 'echo Synced!'
  end
  task :backup, :file, :database do |t, args|
    args.with_defaults(:file => 'backup.sql', :database => 'development')
    config = Rails.application.config.database_configuration

    abort "Missing Database config #{args[:database]}" if config[args[:database]].blank?
    database = config[args[:database]]

    cmd = "mysqldump --opt #{command_args(database)} > sqlbackups/#{args[:file]}"
    system `#{cmd}`
    puts "Backup in sqlbackups/#{args[:file]}"
  end
  task :restore, :file do |t, args|
    args.with_defaults(:file => 'backup.sql', :database => 'development')
    config = Rails.application.config.database_configuration
    dev = config['development']

    abort "Missing Database config #{args[:database]}" if config[args[:database]].blank?
    database = config[args[:database]]

    cmd = "mysql  #{command_args(database)} < #{args[:file]}"
    system "#{cmd}"
    puts "Restored with #{args[:file]}"
  end
end