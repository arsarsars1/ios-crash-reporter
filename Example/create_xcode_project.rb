#!/usr/bin/env ruby
# Creates a minimal Xcode project for CrashReporterExample (CocoaPods wires the crash pod).

require 'fileutils'
require 'securerandom'

def uuid
  SecureRandom.hex(12).upcase
end

example_dir = File.expand_path(__dir__)
proj_dir = File.join(example_dir, 'CrashReporterExample.xcodeproj')
FileUtils.mkdir_p(proj_dir)

target_uuid = uuid
project_uuid = uuid
config_list_proj = uuid
config_list_target = uuid
debug_proj = uuid
release_proj = uuid
debug_target = uuid
release_target = uuid
group_uuid = uuid
products_group = uuid
sources_group = uuid
app_uuid = uuid
info_plist_uuid = uuid
product_ref = uuid
sources_phase = uuid
frameworks_phase = uuid
resources_phase = uuid
build_file_app = uuid

pbxproj = <<~PBXPROJ
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		#{build_file_app} /* CrashReporterExampleApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{app_uuid} /* CrashReporterExampleApp.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		#{app_uuid} /* CrashReporterExampleApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CrashReporterExampleApp.swift; sourceTree = "<group>"; };
		#{info_plist_uuid} /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		#{product_ref} /* CrashReporterExample.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = CrashReporterExample.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		#{frameworks_phase} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		#{group_uuid} = {
			isa = PBXGroup;
			children = (
				#{sources_group} /* CrashReporterExample */,
				#{products_group} /* Products */,
			);
			sourceTree = "<group>";
		};
		#{sources_group} /* CrashReporterExample */ = {
			isa = PBXGroup;
			children = (
				#{app_uuid} /* CrashReporterExampleApp.swift */,
				#{info_plist_uuid} /* Info.plist */,
			);
			path = CrashReporterExample;
			sourceTree = "<group>";
		};
		#{products_group} /* Products */ = {
			isa = PBXGroup;
			children = (
				#{product_ref} /* CrashReporterExample.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		#{target_uuid} /* CrashReporterExample */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = #{config_list_target} /* Build configuration list for PBXNativeTarget "CrashReporterExample" */;
			buildPhases = (
				#{sources_phase} /* Sources */,
				#{frameworks_phase} /* Frameworks */,
				#{resources_phase} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = CrashReporterExample;
			productName = CrashReporterExample;
			productReference = #{product_ref} /* CrashReporterExample.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		#{project_uuid} /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = #{config_list_proj} /* Build configuration list for PBXProject "CrashReporterExample" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = #{group_uuid};
			productRefGroup = #{products_group} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				#{target_uuid} /* CrashReporterExample */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		#{resources_phase} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		#{sources_phase} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{build_file_app} /* CrashReporterExampleApp.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		#{debug_proj} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		#{release_proj} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		#{debug_target} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = CrashReporterExample/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.crashreporter.demo;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		#{release_target} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = CrashReporterExample/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.crashreporter.demo;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		#{config_list_proj} /* Build configuration list for PBXProject "CrashReporterExample" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{debug_proj} /* Debug */,
				#{release_proj} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		#{config_list_target} /* Build configuration list for PBXNativeTarget "CrashReporterExample" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{debug_target} /* Debug */,
				#{release_target} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = #{project_uuid} /* Project object */;
}
PBXPROJ

File.write(File.join(proj_dir, 'project.pbxproj'), pbxproj)
puts "Wrote #{proj_dir}/project.pbxproj"
