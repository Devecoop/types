guard 'rspec', cli: '--format Fuubar --color spec', all_on_start: false, all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch('spec/spec_helper.rb')                       { "spec" }
  watch('app/controllers/application_controller.rb') { "spec/acceptance" }

  watch(%r{^app/controllers/(.+)\.rb})               { |m| "spec/acceptance/#{m[1]}_spec.rb" }
  watch(%r{^app/models/(.+)\.rb})                    { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
end
