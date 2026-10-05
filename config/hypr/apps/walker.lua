-- Application-specific animation
hl.layer_rule({
  match = { namespace = "^(walker|r2-d2-commandbar)$" },
  no_anim = true,
})
