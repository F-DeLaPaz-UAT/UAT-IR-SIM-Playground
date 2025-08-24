Write-Host "Starting IR-SIM Playground Setup..."

# 1. Ensure Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Please install Python and re-run this script."
    exit 1
}

# 2. Create virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "Creating virtual environment..."
    python -m venv .venv
}
else {
    Write-Host "Virtual environment already exists, skipping..."
}

# 3. Activate venv & upgrade pip
Write-Host "Activating virtual environment..."
. .\.venv\Scripts\Activate.ps1   # dot-source so activation persists

Write-Host "Upgrading pip..."
python -m pip install --upgrade pip

# 4. Install IR-SIM & dependencies
Write-Host "Installing IR-SIM with all features..."
pip install ir-sim[all]

# 5. Create starter folders
if (-not (Test-Path "worlds")) { mkdir worlds | Out-Null }
if (-not (Test-Path "examples")) { mkdir examples | Out-Null }
if (-not (Test-Path "docs")) { mkdir docs | Out-Null }

# 6. Create run_sim.py (main runner)
$runner = @'
import irsim, sys

yaml_file = sys.argv[1] if len(sys.argv) > 1 else "worlds/empty_world.yaml"
print(f"Loading world: {yaml_file}")

env = irsim.make(yaml_file)

for i in range(500):
    env.step()
    env.render()
    if env.done():
        break

env.end()
'@

Set-Content -Path "run_sim.py" -Value $runner -Encoding UTF8

# 7. Create sample YAML worlds
$empty = @'
world:
  height: 10
  width: 10
  step_time: 0.05
  sample_time: 0.05

robot:
  - kinematics: {name: 'diff'}
    shape: {name: 'circle', radius: 0.2}
    state: [1, 1, 0]
    goal: [9, 9, 0]
    behavior: {name: 'dash'}
    color: 'g'
    plot:
      show_trajectory: True
      show_goal: True
'@

Set-Content -Path "worlds/empty_world.yaml" -Value $empty -Encoding UTF8

$obstacle = @'
world:
  height: 10
  width: 10

robot:
  - kinematics: {name: 'diff'}
    shape: {name: 'circle', radius: 0.2}
    state: [1, 1, 0]
    goal: [9, 9, 0]
    behavior: {name: 'dash'}
    color: 'b'
    plot:
      show_trajectory: True
      show_goal: True

obstacle:
  - shape: {name: 'circle', radius: 1.0}
    state: [5, 5, 0]
    color: 'k'

  - shape: {name: 'rectangle', length: 2, width: 1}
    state: [6, 2, 0]
    color: 'r'
'@

Set-Content -Path "worlds/obstacle_demo.yaml" -Value $obstacle -Encoding UTF8

# 8. Offline docs launcher
$docsShortcut = @'
@echo off
start "" "docs\html\index.html"
'@
Set-Content -Path "Open_Docs.bat" -Value $docsShortcut -Encoding ASCII

# 9. Finished
Write-Host ""
Write-Host ""
Write-Host "======================================="
Write-Host " IR-SIM Playground setup complete!"
Write-Host "======================================="
Write-Host ""
Write-Host "	Docs available at: .\docs\html\index.html"
Write-Host "   		Or just double-click Open_Docs.bat"
Write-Host ""
Write-Host "	Try sample robot simulations:"
Write-Host "   		python run_sim.py worlds/empty_world.yaml"
Write-Host "   		python run_sim.py worlds/obstacle_demo.yaml"
Write-Host ""
Write-Host "	Your environment is ready — have fun!"
Write-Host ""
Write-Host ""
