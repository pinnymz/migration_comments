# MigrationComments

Comments for your migrations

Tested on:

| ActiveRecord | Ruby |
| :------------ | :------ |
| ActiveRecord 5.0 | Ruby 2.2+ |
| ActiveRecord 4.2 | Ruby 2.1+ |

Status: [<img src="https://travis-ci.org/pinnymz/migration_comments.svg?branch=master" alt="Build Status" />](https://travis-ci.org/pinnymz/migration_comments)

## **IMPORTANT UPDATE**

ActiveRecord 5.0 is introducing baked-in comment support, although not all features provided by this project have yet been completely implemented.
This is expected to be rectified by ActiveRecord 5.1, and as such ActiveRecord 5.0 will likely be the last version for which this gem will work (or be needed).

ActiveRecord 5.0 itself will be supported by this project, but many features are overlapping and you may find that you won't need this gem at all.

For those using a version of ActiveRecord prior to 4.2 or of Ruby prior to 2.1, please use the v0.3.2 version of the gem.

## Why?

Migrations are wonderful.  They handle all your schema changes, and in a pinch they can bring
any database up to speed.  However, database schemas can change rapidly while a project is
maturing, and it can be difficult to know (or remember) the purpose for each table and field.
As such, they deserve to be commented.  These comments should be available for display wherever
those fields are found.

## Solution!

Using MigrationComments, you can simply add comments during your migrations.  Or if you already
have existing data structures, just add the comments afterwards in a separate migration.  And of
course you can always modify and delete these comments in later migrations.

So where are these comments used?  Firstly, they will be included in your `schema.rb` dump which
is where your IDE (e.g. RubyMine, TextMate) should be learning about your model structure.  This means that
they'll be available at any point in your project.  Additionally, if you are using the
[annotate](https://github.com/ctran/annotate_models) gem, these comments will be added to the annotations
that are generated within your <tt>_model_.rb</tt> file.

## Examples

To add a comment to an existing structure...

```ruby
def self.up
  set_table_comment :table_name, "A table comment"
  set_column_comment :table_name, :column_name, "A column comment"
end
```

Or you can use the `change_table` macro...

```ruby
def self.up
  change_table :table_name do |t|
    t.comment = "A table comment"
    t.change_comment :column_name, "A column comment"
  end
end
```

Creating a new table?

```ruby
def self.up
  create_table :table_name, :comment => "A table comment" do |t|
    t.string :column_name, :comment => "A column comment"
  end
end
```

You can also remove comments...

```ruby
def self.up
  remove_table_comment :table_name
  remove_column_comment :table_name, :column_name
end
```

Or you can combine these commands while modifying a table...

```ruby
def self.up
  change_table :existing_table do |t|
    t.comment = nil                                       # remove an existing table comment
    t.string :new_column, :comment => "a new column"    # add a new column with a comment
    t.change_comment :existing_column, nil              # remove a comment on an existing column
    t.integer :another_existing_column, :comment => nil # remove a comment on an existing column while modifying the column type
    t.boolean :column_with_comment                      # modify an existing column without altering the comment
  end
end
```

## Difference between v0.3.x and v0.4.x

To accommodate Rails 5.0, a backwards-incompatible change was made to how table comments are set in `v.0.4.0` and onwards. 

Newer versions of the gem set the comment via an accessor attribute, and thus use an attribute assignment (`=`) to set the comment's value.

In contrast, older versions of the gem (`v0.3.2` and prior) used a method call. 

Examples below:

### Setting table comments in v0.4.0 and above

```ruby
def self.up
  change_table :existing_table do |t|
    t.comment = "a new comment"
  end
end
```

### Setting table comments in older versions

```ruby
def self.up
  change_table :existing_table do |t|
    t.comment "a new comment"
  end
end
```

## Requirements

You must be using a supported DBMS (currently PostgreSQL, MySQL, and SQLite).

If this isn't an option for you, check out the schema_comments gem at [https://github.com/akm/schema_comments](https://github.com/akm/schema_comments).

## Licensing

See MIT-LICENSE file for details.