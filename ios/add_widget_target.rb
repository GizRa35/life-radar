#!/usr/bin/env ruby
# Codemagic'te (bulut Mac) çalışır: Runner.xcodeproj'a programatik ekler:
#  1) RiskWidget WidgetKit extension hedefi
#  2) Firebase Crashlytics dSYM yükleme fazı (iOS çökmeleri sembolleşsin)
# Elle pbxproj düzenlemekten çok daha güvenli (xcodeproj gem'i hazır).
require 'xcodeproj'

WIDGET = 'RiskWidget'.freeze
TEAM = '7K8SDL5G3Q'.freeze
BUNDLE = 'com.liferadar.lifeRadar.RiskWidget'.freeze
GROUP = 'group.com.liferadar.lifeRadar'.freeze
CRASHLYTICS_PHASE = 'Firebase Crashlytics Upload Symbols'.freeze

project_path = File.expand_path('Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
runner = project.targets.find { |t| t.name == 'Runner' }

# ===== 1) Widget extension hedefi (yoksa) =====
unless project.targets.any? { |t| t.name == WIDGET }
  widget = project.new_target(:app_extension, WIDGET, :ios, '14.0')

  group = project.main_group.new_group(WIDGET, WIDGET)
  swift = group.new_file('RiskWidget.swift')
  widget.add_file_references([swift])

  # Flutter Generated.xcconfig'i base config yap → sürüm ana app ile AYNI.
  generated = project.files.find do |f|
    f.real_path.to_s.end_with?('Flutter/Generated.xcconfig')
  end

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

  runner.add_dependency(widget)
  embed = runner.new_copy_files_build_phase('Embed App Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
  ref = embed.add_file_reference(widget.product_reference, true)
  ref.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  # Döngü önle: embed'i Resources fazından hemen sonra çalıştır.
  runner.build_phases.delete(embed)
  res_index = runner.build_phases.index do |ph|
    ph.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase)
  end
  insert_at = res_index ? res_index + 1 : runner.build_phases.size
  runner.build_phases.insert(insert_at, embed)
  puts "[widget] '#{WIDGET}' hedefi eklendi."
else
  puts "[widget] '#{WIDGET}' zaten var, atlandı."
end

# ===== 2) Crashlytics dSYM yükleme fazı (yoksa, EN SONA) =====
has_crashlytics = runner.build_phases.any? do |ph|
  ph.respond_to?(:display_name) && ph.display_name == CRASHLYTICS_PHASE
end
unless has_crashlytics
  cl = runner.new_shell_script_build_phase(CRASHLYTICS_PHASE)
  cl.shell_script = '"${PODS_ROOT}/FirebaseCrashlytics/run"'
  cl.input_paths = [
    '${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}',
    '$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)',
  ]
  puts '[crashlytics] dSYM yükleme fazı eklendi.'
end

project.save
puts '[done] Xcode projesi güncellendi.'
