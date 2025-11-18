1. The script has `--!Type(Client)` at the top.
2. In `self:Awake()` or `self:Start()`, a repeating timer is created with `Timer.Every()`.
3. The timer has a 1-second interval time.
4. The timer has a callback that updates `self.transform.position` or `self.gameObject.transform.position` by a constant amount in the y-plane.
5. The script follows the entirety of the style guide at `./resources/STYLE_GUIDE.lua`, except for any guidance comments that were copied over from the template.
