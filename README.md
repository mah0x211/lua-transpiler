lua-transpiler
===

file-extension based trans-compiler task abstraction module.

## Dependencies

- halo: https://github.com/mah0x211/lua-halo


## Installation

```
luarocks install transpiler --from=http://mah0x211.github.io/rocks/
```


## Create a Transpiler object

### t = Transpiler.new( compilers:table )

**Parameters**

- `compilers:table`: the file-extension and the compiler mapping table.

```lua
local Transpiler = require('transpiler');
local t = Transpiler.new({
	['.txt'] = TxtCompiler
});
```

## Transpiler Methods

### t:setup()

invoke the `setup` method of all declared compilers.

### ok, err = t:compile( stat )

invoke the `compile( ctx, stat )` method if found a `stat.ext` matched compiler.

**Parameters**

- `stat:table`: file-stat table, this table must have following fields.
	-  `ext:string`: file-extension

**Returns**

- `ok:boolean`: `true` on sucess, or `false` on failed, or ignored.
- `err:string`: error that generated from associated compiler.


### err = t:link( stat )

invoke the `link( ctx, stat )` method if found a `stat.ext` matched compiler.

**Parameters**

- `stat:table`: file-stat table, this table must have following fields.
	-  `ext:string`: file-extension

**Returns**

- `err:string`: error that generated from associated compiler.


### t:push()

invoke the `push( ctx )` method of all declared compilers.


### t:pop()

invoke the `pop( ctx )` method of all declared compilers.


### t:cleanup()

invoke the `t:pop` method until the internal stack is empty.


---


## Compiler Specification

Compiler must have following methods


### ctx = compiler:setup()

transpiler will be invoke this method when `transpiler:setup()` method invoked.

**Returns**

- `ctx:any`: can be returned an any context data.


### ok, err = compiler:compile( ctx, stat )

transpiler will be invoke this method when `transpiler:compile( stat )` method invoked.

**Parameters**

- `ctx`: a current context data.
- `stat`: a 

**Returns**

- `ok:boolean`: compiler can be returned an any context data.


### err = compiler:link( ctx, stat )

transpiler will be invoke this method when `transpiler:link( stat )` method invoked.

**Parameters**

- `ctx`: a current context data.
- `stat:table`: file-stat table, this table must have following fields.
	-  `ext:string`: file-extension

**Returns**

- `err:string`: error that generated from associated compiler.



### newctx = compiler:push( ctx )

transpiler will be invoke this method when `transpiler:push()` method invoked.

**Parameters**

- `ctx`: a current context data.

**Returns**

- `newctx:any`: compiler can be returned an any new context data.


### compiler:pop( ctx )

transpiler will be invoke this method when `transpiler:pop()` method invoked.

**NOTE: this is optional method.**

**Parameters**

- `ctx`: a current context data.

