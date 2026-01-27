#!/usr/bin/env python3
"""
Add a Run Script build phase to Xcode project to fix framework structures.
This automates the manual Xcode steps described in XCODE_BUILD_PHASE_SETUP.md
"""

import sys
import re
import uuid

def generate_xcode_id():
    """Generate a unique 24-character hex ID for Xcode objects"""
    return uuid.uuid4().hex[:24].upper()

def add_build_phase(project_path):
    """Add Run Script build phase to Runner target in project.pbxproj"""

    with open(project_path, 'r') as f:
        content = f.read()

    # Check if already added
    if 'Fix Framework Structures' in content or 'fix_frameworks.sh' in content:
        print("✓ Build phase already exists in project")
        return True

    # Generate unique IDs for the build phase
    script_phase_id = generate_xcode_id()

    # Create the shell script build phase section
    shell_script_section = f'''\t\t{script_phase_id} /* Fix Framework Structures */ = {{
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tinputPaths = (
\t\t\t);
\t\t\tname = "Fix Framework Structures";
\t\t\toutputPaths = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/bash;
\t\t\tshellScript = "\\"$SRCROOT/fix_frameworks.sh\\"\\n";
\t\t}};
'''

    # Find the section to insert the shell script build phase
    # Insert after /* Begin PBXShellScriptBuildPhase section */
    pattern = r'(/\* Begin PBXShellScriptBuildPhase section \*/\n)'
    replacement = r'\1' + shell_script_section
    content = re.sub(pattern, replacement, content)

    # Find the Runner target's buildPhases array and add our phase
    # Look for the Bundle Framework phase and add ours after it
    bundle_framework_pattern = r'(33CC110E2044A8840003C045 /\* Bundle Framework \*/,\n)'
    replacement_phase = r'\1\t\t\t\t' + script_phase_id + r' /* Fix Framework Structures */,\n'
    content = re.sub(bundle_framework_pattern, replacement_phase, content)

    # Write back
    with open(project_path, 'w') as f:
        f.write(content)

    print(f"✓ Added 'Fix Framework Structures' build phase to Xcode project")
    print(f"  Phase ID: {script_phase_id}")
    return True

def main():
    project_path = 'macos/Runner.xcodeproj/project.pbxproj'

    print("Adding Run Script build phase to Xcode project...")
    print(f"Project path: {project_path}")

    try:
        if add_build_phase(project_path):
            print("\n✓ Successfully configured Xcode project")
            print("\nNext steps:")
            print("1. Run: flutter build macos --release")
            print("2. Open macos/Runner.xcworkspace in Xcode")
            print("3. Product > Archive")
            print("4. Validate or upload to App Store Connect")
        else:
            print("\n✗ Failed to add build phase")
            sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        print("\nPlease add the build phase manually using XCODE_BUILD_PHASE_SETUP.md")
        sys.exit(1)

if __name__ == '__main__':
    main()
