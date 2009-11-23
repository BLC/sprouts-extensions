require 'sprout'
sprout 'as3'

# enable github as a source
Sprout::Sprout.gem_sources += ['http://gems.github.com']

Sprout::ToolTask.class_eval do
  # namespace respecting alias for this task.
  # ToolTask is a file_task which generally doesn't respect namespacing.
  # Since we DO want to namespace these commands, we're going to create the non-namespaced version
  # and then build a task which is namespaced that just invokes the real one.
  # Feels shady, but less shady than other solutions.
  def task_alias=(task_alias)
    desc name
    task task_alias => name
  end
end

Sprout::ToolTask.class_eval do
  def switch_param_type(name, type)
    original_param = param_hash[name]
    params.delete original_param

    new_param = create_param(type)
    new_param.init do |p|
      p.belongs_to = self
      p.name = name
      p.type = type
      yield p if block_given?
    end

    param_hash[name] = new_param
    params << new_param
  end
end

Sprout::MXMLCTask.class_eval do
  def initialize_task_with_fixed_rsls(*args)
    value = initialize_task_without_fixed_rsls(*args)
    switch_param_type('runtime_shared_library_path', 'strings')
    value
  end

  alias_method :initialize_task_without_fixed_rsls, :initialize_task
  alias_method :initialize_task, :initialize_task_with_fixed_rsls
end


# make the task a little smarter about how it determines when it needs to rebuild. Normally it bases
# this on the name of the task, but since these sprout tasks explicitly have an output file, use that
# instead.
[Sprout::COMPCTask, Sprout::MXMLCTask].each do |task_class|
  task_class.class_eval do
    def self.needed?()
      ! File.exist?(output) || out_of_date?(timestamp)
    end

    def timestamp
      if File.exist?(output)
        File.mtime(output.to_s)
      else
        Rake::EARLY
      end
    end
  end
end