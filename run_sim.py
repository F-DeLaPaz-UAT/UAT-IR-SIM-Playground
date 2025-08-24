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
