local process = require("@lune/process")

local exports = {}
export type ChildProcessReader = typeof(({} :: process.ChildProcess).stdout)

local CHUNK_SIZE = 8 * 1024 -- 8 KB

--- Luau implementation of `ChildReader:readToEnd`.
---
--- This is a workaround for a lune bug which causes child processes to
--- never exit.
---
--- ## The Bug
---
--- When a command such as `unzip` is spawned, a pipe is established between
--- lune's stdin and and the `unzip`'s stdout. The pipe buffer has a fixed size
--- which must not be overflowed, and hence processes yield writing to it, and
--- wait for the consumer to read the data being written.
---
--- `process.create` and `process.exec` wait for the process to exit first, before
--- calling `read_to_end` on the stream, which works for processes with small outputs,
--- but for larger ones such as `unzip`'s which involve the process itself waiting for
--- consumption of data, it creates a cyclic yielding dependence where lune waits for the
--- process to exit, which wouldn't happen until it finishes writing its data, which in turn
--- would only happen if it can continue writing chunks after the previous data has been read
--- (which lune is waiting for the process to exit to begin doing).
function exports.readToEnd(reader: ChildProcessReader): string
  local chunks = {}
  while true do
    local chunk = reader:read(CHUNK_SIZE)
    if chunk == nil then
      break
    end

    table.insert(chunks, chunk)
  end

  return table.concat(chunks)
end

--- Streamed comparison of a reader against an expected value. Useful for comparison of large
--- streams of data.
function exports.readerEq(reader: ChildProcessReader, expected: string): boolean
  local offset = 0

  while true do
    local chunk = reader:read(CHUNK_SIZE)
    if chunk == nil then
      return offset == #expected
    end

    if chunk ~= string.sub(expected, offset + 1, offset + #chunk) then
      return false
    end

    offset += #chunk
  end
end

return exports
