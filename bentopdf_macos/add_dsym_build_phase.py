#!/usr/bin/env python3
"""
Add a Run Script build phase to create dSYM for objective_c framework.
"""

import sys
import re
import uuid

def generate_xcode_id():
    """Generate a unique 24-character hex ID for Xcode objects"""
    return uuid.uuid4().hex[:24].upper()

def add_dsym_build_phase(project_path):
    """Add Run Script build phase for dSYM creation to Runner target in project.pbxproj"""

    with open(project_path, 'r') as f:
        content = f.read()

    # Check if already added
    if 'Create objective_c dSYM' in content or 'create_objective_c_dsym.sh' in content:
        print("✓ dSYM build phase already exists in project")
        return True

    # Generate unique IDs for the build phase
    script_phase_id = generate_xcode_id()

    # Create the shell script build phase section
    shell_script_section = f'''\t\t{script_phase_id} /* Create objective_c dSYM */ = {{
\t\t\tisa = PBXShellScriptBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\tinputPaths = (
\t\t\t);
\t\t\tname = "Create objective_c dSYM";
\t\t\toutputPaths = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t\tshellPath = /bin/bash;
\t\t\tshellScript = "\\"$SRCROOT/create_objective_c_dsym.sh\\"\\n";
\t\t}};
'''

    # Find the section to insert the shell script build phase
    # Insert after /* Begin PBXShellScriptBuildPhase section */
    pattern = r'(/\* Begin PBXShellScriptBuildPhase section \*/\n)'
    replacement = r'\1' + shell_script_section
    content = re.sub(pattern, replacement, content)

    # Find the Runner target's buildPhases array
    runner_pattern = r'(33CC10E92044A3C60003C045 /\* Runner \*/ = \{[^}]*?buildPhases = \(\n)((?:\s+[A-F0-9]+ /\*[^*]*\*/,\n)*)'

    def add_to_build_phases(match):
        prefix = match.group(1)
        phases = match.group(2)
        # Add our new phase at the end
        new_phase = f'\t\t\t\t{script_phase_id} /* Create objective_c dSYM */,\n'
        return prefix + phases + new_phase

    content = re.sub(runner_pattern, add_to_build_phases, content)

    # Write back
    with open(project_path, 'w') as f:
        f.write(content)

    print(f"✓ Added 'Create objective_c dSYM' build phase to Xcode project")
    print(f"  Phase ID: {script_phase_id}")
    return True

def main():
    project_path = 'macos/Runner.xcodeproj/project.pbxproj'

    print("Adding dSYM creation build phase to Xcode project...")
    print(f"Project path: {project_path}")

    try:
        if add_dsym_build_phase(project_path):
            print("\n✓ Successfully configured Xcode project")
            print("\nNext steps:")
            print("1. Run: flutter clean")
            print("2. Run: flutter build macos --release")
            print("3. Open macos/Runner.xcworkspace in Xcode")
            print("4. Product > Archive")
            print("5. Validate and upload to App Store Connect")
        else:
            print("\n✗ Failed to add build phase")
            sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
