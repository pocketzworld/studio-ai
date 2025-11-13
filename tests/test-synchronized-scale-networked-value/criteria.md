1. The script has `--!Type(ClientAndServer)` at the top.
2. There is a networked value declared with `local` outside of any function's scope. The name can be anything.
2. In `self:ServerUpdate()`, the networked value is updated, scaling by `Time.deltaTime` for smoothness.
3. In `self:ServerUpdate()`, the networked value is updated using `NAME.value = ...`, not directly assigning to `NAME = ...`.
3. In `self.ClientAwake()` or `self.ClientStart()`, an event is connected using `NAME.Changed:Connect()`.
4. The callback to the `Connect()` call updates the scale of the gameobject by setting `self.transform.localScale` or `self.gameObject.transform.localScale` using the value passed as an argument to the callback.
5. The script follows the entirety of the style guide at `./resources/STYLE_GUIDE.lua`.