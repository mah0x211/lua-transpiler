--[[

  Copyright (C) 2015 Masatoshi Teruya
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  transpiler.lua
  lua-transpiler
  Created by Masatoshi Teruya on 15/09/11.

--]]

-- constants
local EINVAL = 'compilers must be table';
local EINVALKEY = 'key %q of compilers must be started with ".".';
local EINVALVAL = 'compiler.%s must be function';

-- class
local Transpiler = require('halo').class.Transpiler;

--[[
    compilers = {
        ext = compiler,
        ...
    }
--]]
function Transpiler:init( compilers )
    local own = protected( self );
    
    -- check arguments
    assert( type( compilers ) == 'table' , EINVAL );
    
    -- append compilers
    own.compilers = {};
    for ext, compiler in pairs( compilers ) do
        if not ext:find('^%.') then
            error( EINVALIDKEY:format( k ) );
        end
        
        -- check required methods
        for k, t in pairs({
            setup = 'function',
            push = 'function',
            pop = 'function',
            compile = 'function',
            link = 'function',
        }) do
            if type( compiler[k] ) ~= t then
                error( EINVALVAL:format( k ) );
            end
        end
        
        own.compilers[ext] = compiler;
    end
    
    return self;
end


function Transpiler:setup()
    local own = protected( self );
    local ctx = {};
    
    -- setup and get initial context
    for ext, compiler in pairs( own.compilers ) do
        ctx[ext] = compiler:setup();
    end
    own.stack = { ctx };
end


function Transpiler:cleanup()
    -- remove context sequentially
    while self:pop() do
    end
end


function Transpiler:push( rpath )
    local own = protected( self );
    local compilers = own.compilers;
    local stack = own.stack;
    local ctx = stack[#stack];
    local newctx = {};
    
    -- get new context
    for ext, compiler in pairs( compilers ) do
        newctx[ext] = compiler:push( ctx[ext] );
    end
    -- push new context
    stack[#stack + 1] = newctx;
end


function Transpiler:pop()
    local own = protected( self );
    local stack = own.stack;
    local poppabale = #stack > 0;
    
    if poppabale then
        local compilers = own.compilers;
        local ctx = stack[#stack];
        
        -- cleanup context
        for ext, compiler in pairs( compilers ) do
            compiler:pop( ctx[ext] );
        end
        
        -- remove current context
        stack[#stack] = nil;
    end
    
    return poppable;
end


function Transpiler:compile( stat )
    local own = protected( self );
    local compiler = own.compilers[stat.ext];
    local ok, err;
    
    if compiler then
        ok, err = compiler:compile( own.stack[#own.stack][stat.ext], stat );
    end
    
    return ok == true, err;
end


function Transpiler:link( stat )
    local own = protected( self );
    local compiler = own.compilers[stat.ext];
    local err;
    
    if compiler then
        err = compiler:link( own.stack[#own.stack][stat.ext], stat );
    end
    
    return err;
end


return Transpiler.exports;
