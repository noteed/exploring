-- The parts are hard-coded within the source code and refer to resources into
-- memlist. The IDs are from
-- https://github.com/fabiensanglard/Another-World-Bytecode-Interpreter/blob/master/src/parts.h.

CREATE TABLE parts (
  id INTEGER,
  palette INTEGER,
  bytecode INTEGER,
  cinematics INTEGER,
  characters INTEGER,
  comment TEXT,
  FOREIGN KEY (palette) REFERENCES memlist (id),
  FOREIGN KEY (bytecode) REFERENCES memlist (id),
  FOREIGN KEY (cinematics) REFERENCES memlist (id),
  FOREIGN KEY (characters) REFERENCES memlist (id)
);

INSERT INTO parts (id, palette, bytecode, cinematics, characters, comment) VALUES
  (0x3E80, 0x14, 0x15, 0x16, 0x00, "protection screens"),
  (0x3E81, 0x17, 0x18, 0x19, 0x00, "introduction cinematic"),
  (0x3E82, 0x1A, 0x1B, 0x1C, 0x11, "water"),
  (0x3E83, 0x1D, 0x1E, 0x1F, 0x11, "suspended sail"),
  (0x3E84, 0x20, 0x21, 0x22, 0x11, "cite"),
  (0x3E85, 0x23, 0x24, 0x25, 0x00, "battlechar cinematic"),
  (0x3E86, 0x26, 0x27, 0x28, 0x11, "luxe"),
  (0x3E87, 0x29, 0x2A, 0x2B, 0x11, "final"),
  (0x3E88, 0x7D, 0x7E, 0x7F, 0x00, "password screen"),
  (0x3E89, 0x7D, 0x7E, 0x7F, 0x00, "password screen");
