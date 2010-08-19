module MigrationHelpers

  def foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    
    execute %{alter table #{from_table} add constraint #{constraint_name} foreign key (#{from_column}) references #{to_table}(id) on delete cascade}
  end
  
  def foreign_key_on_delete_set_null(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    
    execute %{alter table #{from_table} add constraint #{constraint_name} foreign key (#{from_column}) references #{to_table}(id) on delete set null}
  end

  def before_delete_trigger(table,statements)
    sql = <<-_SQL
    ^
    create trigger `delete_#{table}` before delete on `#{table}`
    for each row
    begin
      #{statements}
    end
    ^
    _SQL
    sql.split('^').each do |stmt|
      execute(stmt) if (stmt.strip! && stmt.length > 0)
    end
  end

end