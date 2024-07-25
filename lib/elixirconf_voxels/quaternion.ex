defmodule Quaternion do
  import Nx.Defn

  defn euler(roll, pitch, yaw) do
    cr = Nx.cos(roll / 2)
    sr = Nx.sin(roll / 2)
    cp = Nx.cos(pitch / 2)
    sp = Nx.sin(pitch / 2)
    cy = Nx.cos(yaw / 2)
    sy = Nx.sin(yaw / 2)

    Nx.stack([
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy
    ])
  end
end
