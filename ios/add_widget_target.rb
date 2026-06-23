#!/usr/bin/env ruby
# Codemagic'te (bulut Mac) çalışır: RiskWidget WidgetKit extension hedefini
# Runner.xcodeproj'a programatik olarak ekler. Elle pbxproj düzenlemekten çok
# daha güvenli (xcodeproj gem'i CocoaPods ile zaten kurulu).
require 'xcodeproj'

WIDGET = 'RiskWidget'.freeze
TEAM = '7K8SDL5G3Q'.freeze
BUNDLE = 'com.liferadar.lifeRadar.RiskWidget'.freeze
GROUP = 'group.com.liferadar.lifeRadar'.freeze

project_path = File.expand_path('Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

if project.targets.any? { |t| t.name == WIDGET }
  puts "[widget] '#{WIDGET}' hedefi zaten var, atlanıyor."
  exit 0
end

# 1) App-extension hedefi (iOS 14 — WidgetKit gereği)
widget = project.new_target(:app_extension, WIDGET, :ios, '14.0')

# 2) Kaynak grubu + Swift dosyası
group = project.main_group.new_group(WIDGET, WIDGET)
swift = group.new_file('RiskWidget.swift')
widget.add_file_references([swift])

# 3) Flutter Generated.xcconfig'i base config yap → sürüm (FLUTTER_BUILD_*)
#    ana uygulamayla AYNI olsun (Apple extension sürüm eşleşmesi şartı).
generated = project.files.find do |f|
  f.real_path.to_s.end_with?('Flutter/Generated.xcconfig')
end

# 4) Build ayarları
widget.build_configurations.each do |c|
  c.base_configuration_reference = generated if generated
  bs = c.build_settings
  bs['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE
  bs['INFOPLIST_FILE'] = "#{WIDGET}/Info.plist"
  bs['CODE_SIGN_ENTITLEMENTS'] = "#{WIDGET}/RiskWidget.entitlements"
  bs['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  bs['SWIFT_VERSION'] = '5.0'
  bs['TARGETED_DEVICE_FAMILY'] = '1,2'
  bs['CODE_SIGN_STYLE'] = 'Manual'
  bs['DEVELOPMENT_TEAM'] = TEAM
  bs['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  bs['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  bs['GENERATE_INFOPLIST_FILE'] = 'NO'
  bs['PRODUCT_NAME'] = '$(TARGET_NAME)'
  bs['LD_RUNPATH_SEARCH_PATHS'] =
    ['$(inherited)', '@executable_path/Frameworks',
     '@executable_path/../../Frameworks']
end

# 5) Runner → widget bağımlılığı + "Embed App Extensions"
runner = project.targets.find { |t| t.name == 'Runner' }
runner.add_dependency(widget)
embed = runner.new_copy_files_build_phase('Embed App Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
ref = embed.add_file_reference(widget.product_reference, true)
ref.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Döngü (cycle) önle: "Embed App Extensions"ı Flutter/Pods script fazlarından
# ÖNCE çalıştır. new_copy_files_build_phase fazı sona ekler; ilk shell-script
# fazından (Flutter "Run Script") hemen öncesine taşı.
runner.build_phases.delete(embed)
script_index = runner.build_phases.index do |ph|
  ph.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
end
runner.build_phases.insert(script_index || runner.build_phases.size, embed)

project.save
puts "[widget] '#{WIDGET}' hedefi eklendi (bundle: #{BUNDLE}, group: #{GROUP})."
