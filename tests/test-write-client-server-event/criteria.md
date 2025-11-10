1. The script has `--!Type(ClientAndServer)` at the top.
2. `local eventName = Event.new("SomeName")` call outside of the scope of any function. The names can be anything.
3. An `eventName:Connect()` call in `self:ClientStart()` or `self:ClientAwake()`.
4. A callback is passed to `eventName:Connect()` that executes `print("happy day!")`.
5. In `self:ServerAwake()` or `self:ServerStart()`, a repeating timer is created with `Timer.Every()`.
6. The timer has a 1-second interval time.
7. The timer has a callback that executes `eventName:FireAllClients()`.
8. The script follows the entirety of the style guide at `STYLE_GUIDE.md`. Read and evaluate against every part of the guide in detail.