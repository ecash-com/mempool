# mempool-ecx

A fork of [mempool/mempool](https://github.com/mempool/mempool), the block
explorer for the eCash alphanet. See the upstream repo for general
documentation and installation instructions.

The `ecx` branch is a rebasable patch series on top of an upstream release
tag — currently **v3.3.1** — kept as one commit per change; see
`git log v3.3.1..ecx` for what and why.

## Rebasing onto a new release

```sh
git fetch upstream --tags
git rebase --onto v3.4.0 v3.3.1 ecx      # old base -> new base
./frontend/check-ecx-units.sh
```

Then re-verify by hand: the meta tags in `src/index.mempool.html`, the fork
height in `app/app.constants.ts`, and the removed routes in
`app/master-page.module.ts` — then `npm run build` and walk a block, tx, and
address page.
