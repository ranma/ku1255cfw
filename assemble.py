#!/usr/bin/env python3
#
# vim:ts=2 et:

import operator

from typing import Any

from dataclasses import dataclass
from sly import Lexer, Parser


@dataclass(frozen=True)
class Immediate:
  value: Any

  @staticmethod
  def valid(other):
    return type(other) == int or isinstance(other, Immediate)


@dataclass(frozen=True)
class Address:
  value: int
  space: str

  def __eq__(self, other):
    if type(other) == int:
      return self.value == other
    return super().__eq__(other)

  def __add__(self, other):
    if type(other) == int:
      return Address(self.value + other, self.space)
    raise TypeError('Can only add int to Address')

  def __radd__(self, other):
    return self.__add__(other)

  def __and__(self, other):
    if type(other) != int:
      raise TypeError('Can only mask Address by int')
    return Address(self.value & other, self.space)

  def __ror__(self, other):
    if type(other) != int:
      raise TypeError('Can only ror Address by int')
    return other | self.value

  def __mul__(self, other):
    if type(other) == int:
      return Address(self.value * other, self.space)
    raise TypeError('Can only mul Address with int')

  def __rmul__(self, other):
    return self.__mul__(other)

  def __floordiv__(self, other):
    if type(other) != int:
      raise TypeError('Can only divide Address by int')
    return Address(self.value // other, self.space)

  def checkType(self, other):
    if not isinstance(other, Address):
      raise TypeError('Incompatible types: %r + %r' % (type(self), type(other)))
    if self.space != other.space:
      raise TypeError('Incompatible space: %r + %r' % (self.space, other.space))

  @staticmethod
  def valid(other):
    return type(other) == int or isinstance(other, Address)


class Acc:
  @staticmethod
  def valid(other):
    return isinstance(other, Acc)

  def __repr__(self):
    return 'ACC'


@dataclass(frozen=True)
class OpCode:
  code: int
  name: str
  operands: tuple

  def emit(self, *args) -> int:
    value = 0
    if len(self.operands) != len(args):
      raise ValueError('Expected %d args, got %d' % (len(self.operands), len(args)))
    i = 0
    for o, a in zip(self.operands, args):
      i += 1
      if isinstance(o, Address) and not o == a:
        raise ValueError('Expected address %r, got %r' % (o, a))
      elif not o.valid(a):
        raise ValueError('Expected type %s, got %r' % (type(o), a))
      if o in (Immediate, Address):
        if type(a) == int:
          value = a
        else:
          value = Evaluable.eval(a.value)

    if self.code >= 0x80:
      # JMP or CALL
      value &= 0x3fff
    elif self.code >= 0x40:
      # Operations on bit address
      addr = (value // 8) & 0xff
      bit = value & 7
      value = addr | (bit << 8)
    else:
      # Normal address or immediate
      value &= 0xff

    return (self.code << 8) | value


_ACC = Acc()
REG_R = Address(0x82, 'DATA')
REG_Z = Address(0x83, 'DATA')
REG_Y = Address(0x84, 'DATA')
REG_PFLAG = Address(0x86, 'DATA')
REG_RBANK = Address(0x87, 'DATA')
BitAddress = Address
OPCODES = set(map(lambda x: OpCode(*x), (
  (0x00, 'NOP',    ()),
  (0x02, 'B0XCH',  (Acc, Address)),
  (0x03, 'B0ADD',  (Address, Acc)),
  (0x04, 'PUSH',   ()),
  (0x05, 'POP',    ()),
  (0x06, 'CMPRS',  (Acc, Immediate)),
  (0x07, 'CMPRS',  (Acc, Address)),
  (0x08, 'RRC',    (Address,)),
  (0x09, 'RRCM',   (Address,)),
  (0x0a, 'RLC',    (Address,)),
  (0x0b, 'RLCM',   (Address,)),
  (0x0d, 'MOVC',   ()),
  (0x0e, 'RET',    ()),
  (0x0f, 'RETI',   ()),
  (0x10, 'ADC',    (Acc, Address)),
  (0x11, 'ADC',    (Address, Acc)),
  (0x12, 'ADD',    (Acc, Address)),
  (0x13, 'ADD',    (Address, Acc)),
  (0x14, 'ADD',    (Acc, Immediate)),
  (0x15, 'INCS',   (Address,)),
  (0x16, 'INCMS',  (Address,)),
  (0x17, 'SWAP',   (Address,)),
  (0x18, 'OR',     (Acc, Address)),
  (0x19, 'OR',     (Address, Acc)),
  (0x1a, 'OR',     (Acc, Immediate)),
  (0x1b, 'XOR',    (Acc, Address)),
  (0x1c, 'XOR',    (Address, Acc)),
  (0x1d, 'XOR',    (Acc, Immediate)),
  (0x1e, 'MOV',    (Acc, Address)),
  (0x1f, 'MOV',    (Address, Acc)),
  (0x20, 'SBC',    (Acc, Address)),
  (0x21, 'SBC',    (Address, Acc)),
  (0x22, 'SUB',    (Acc, Address)),
  (0x23, 'SUB',    (Address, Acc)),
  (0x24, 'SUB',    (Acc, Immediate)),
  (0x25, 'DECS',   (Address,)),
  (0x26, 'DECMS',  (Address,)),
  (0x27, 'SWAPM',  (Address,)),
  (0x28, 'AND',    (Acc, Address)),
  (0x29, 'AND',    (Address, Acc)),
  (0x2a, 'AND',    (Acc, Immediate)),
  (0x2b, 'CLR',    (Address)),
  (0x2c, 'XCH',    (Acc, Address)),
  (0x2d, 'MOV',    (Acc, Immediate)),
  (0x2e, 'B0MOV',  (Acc, Address)),
  (0x2f, 'B0MOV',  (Address, Acc)),
  (0x32, 'B0MOV',  (REG_R, Immediate)),
  (0x33, 'B0MOV',  (REG_Z, Immediate)),
  (0x34, 'B0MOV',  (REG_Y, Immediate)),
  (0x36, 'B0MOV',  (REG_PFLAG, Immediate)),
  (0x37, 'B0MOV',  (REG_RBANK, Immediate)),
  (0x40, 'BCLR',   (BitAddress,)),
  (0x48, 'BSET',   (BitAddress,)),
  (0x50, 'BTS0',   (BitAddress,)),
  (0x58, 'BTS1',   (BitAddress,)),
  (0x60, 'B0BCLR', (BitAddress,)),
  (0x68, 'B0BSET', (BitAddress,)),
  (0x70, 'B0BTS0', (BitAddress,)),
  (0x78, 'B0BTS1', (BitAddress,)),
  (0x80, 'JMP',    (Address,)),
  (0xc0, 'CALL',   (Address,)),
)))
OPCODE_NAMES = set([o.name for o in OPCODES])


class Context:

  def __init__(self):
    self.scope_stack = [Scope()]
    self.sections = {}
    self.current_section = None
    self.identifiers = {}
    self.labels = {}

  @property
  def current_scope(self):
    return self.scope_stack[-1]

  @property
  def allocator(self):
    return self.current_section.allocator

  def new_scope(self):
    self.scope_stack.append(Scope())

  def leave_scope(self):
    if len(self.scope_stack) <= 1:
      raise Exception('Can\'t leave root scope')
    self.scope_stack.pop()

  def add_label(self, name, lineno):
    l = Label(lineno=lineno, section=self.current_section, val=0)
    self.add_identifier(name=name, lineno=lineno, val=l, typ=Identifier.LABEL)
    return l

  def sorted_relref_labels(self):
    return sorted([
      i for i in self.identifiers.values()
      if (i.name.startswith('@@') and isinstance(i.val, Label))
    ], key=lambda x: x.lineno)

  def relref_backward(self, lineno):
    name = None
    for l in self.sorted_relref_labels():
      if l.lineno < lineno:
        name = l.name
      else:
        break
    if not name:
      raise ValueError('No labels before line %d' % lineno)
    return name

  def relref_forward(self, lineno):
    for l in self.sorted_relref_labels():
      if l.lineno < lineno:
        continue
      return l.name
    raise ValueError('No labels after line %d' % lineno)

  def add_identifier(self, name, typ=None, val=None, lineno=None):
    if name == '@@':
      name = f'@@{lineno}'
    if name in self.identifiers:
      raise ValueError('Identifier %r already exists: %r' % (name, self.identifiers[name]))
    i = Identifier(name=name, lineno=lineno, typ=typ, val=val)
    self.identifiers[name] = i
    return i

  def find_identifier(self, name, lineno=None):
    if name == '@B':
      name = self.relref_backward(lineno)
    elif name == '@F':
      name = self.relref_forward(lineno)
    return self.identifiers.get(name, None)

  def eval(self, val):
    return Evaluable.eval(val)

  def apply(self, s):
    if not isinstance(s, Node):
      raise ValueError('Statement not a node: %r' % s)
    clsname = s.__class__.__name__
    fn = getattr(self, 'apply_%s' % clsname.lower(), None)
    if fn:
      fn(s)
      return
    fn = getattr(s, 'apply', None)
    if not fn:
      raise ValueError('Missing apply fn for node %s: %r' % (clsname, s))
    s.apply(self)

  def apply_section(self, s):
    section = self.sections[s.name]
    self.current_section = section

  def apply_definespace(self, s):
    if hasattr(s, 'label'):
      self.update_label(s.label)
    size = self.eval(s.size)
    self.allocator.allocate(size)

  def apply_definedata(self, s):
    if s.typ not in ('DB', 'DW'):
      raise ValueError('Unsupported data definition: %s' % s.typ)
    if hasattr(s, 'label'):
      self.update_label(s.label)
    mask, fn = {
      'DB': (0x00ff, lambda x: [x]),
      'DW': (0xffff, lambda x: [x & 0xff, x >> 8]),
    }.get(s.typ)
    self.allocator.byte_align(len(fn(0)))
    data = []
    for arg in s.args:
      val = self.eval(arg)
      if type(val) == int:
        if val > mask:
          raise ValueError('Data out of range at line %d: %d > %d' % (s.lineno, val, mask))
        data.extend(fn(val))
      elif type(val) == str:
        for c in val:
          data.extend(fn(ord(c)))
      else:
        raise ValueError('Unexpected type: %r' % val)
    self.allocator.allocate(data)

  def apply_org(self, s):
    addr = self.eval(s.expr)
    self.allocator.org(addr)

  def apply_align(self, s):
    size = self.eval(s.expr)
    self.allocator.align(size)

  def update_label(self, l):
    if not isinstance(l, Label):
      raise ValueError('Invalid label: %r' % l)
    # Word-align the label when in the code segment.
    ctx.allocator.align(1)
    l.val = Address(self.allocator.address, self.current_section.name)


class Scope:

  def __init__(self):
    pass


class Section:

  def __init__(self, name):
    self.name = name
    self.allocator = Allocator(2 if name == '.CODE' else 1)
    self.statements = []


class Range:

  def __init__(self, start, end, data):
    self.start = start
    self.end = end
    self.data = data

  def intersects(self, other) -> bool:
    start = max(self.start, other.start)
    end = min(self.end, other.end)
    if start >= end:
      return False
    return True

  def merge(self, other):
    if self.end == other.start:
      return Range(self.start, other.end, self.data + other.data)
    if self.start == other.end:
      return Range(other.start, self.end, other.data + self.data)
    return None

  def __repr__(self):
    return 'Range[%d, %d)=%r' % (self.start, self.end, self.data)


class Allocator:

  def __init__(self, base_size):
    self.base_size = base_size
    self.reset()

  def reset(self):
    self.current_address = 0
    self.allocated = []

  @property
  def address(self):
    return (self.current_address + self.base_size - 1) // self.base_size

  def org(self, address):
    if type(address) != int:
      raise ValueError('address must be int: %r' % address)
    self.current_address = address * self.base_size

  def align(self, granularity):
    self.byte_align(self.base_size * granularity)

  def byte_align(self, granularity):
    rem = self.current_address % granularity
    if not rem:
      return
    self.allocate(granularity - rem)

  def allocate(self, count_or_data):
    count = 0
    data = []
    if type(count_or_data) == int:
      count = count_or_data
      data = [0] * count_or_data
    else:
      count = len(count_or_data)
      data = count_or_data
    if count == 0:
      return
    if count < 0:
      raise ValueError('Cannot allocate negative count: %d' % count)

    start = self.current_address
    newr = Range(start=start, end=start + count, data=data)
    for r in self.allocated:
      if r.intersects(newr):
        raise ValueError('Address %d already in use: %r' % (start, r))

    self.current_address += count
    for i in range(len(self.allocated)):
      merged =  self.allocated[i].merge(newr)
      if merged:
        self.allocated[i] = merged
        if i != 0:
          self.allocated[i] = self.allocated[0]
          self.allocated[0] = merged
        return start

    self.allocated = [newr] + self.allocated
    return start

  def __repr__(self):
    return 'Allocator(%r)' % self.allocated


class Node:

  def __init__(self, *, mustkwarg=None, **kwargs):
    assert 'lineno' in kwargs
    self._kwargs = kwargs

  def __getattr__(self, name):
    if name.startswith('_'):
      return super().__getattr__(name)
    if name not in self._kwargs:
      raise AttributeError
    return self._kwargs[name]

  def __setattr__(self, name, value):
    if name.startswith('_'):
      super().__setattr__(name, value)
      return
    self._kwargs[name] = value

  def repr_format(self, fmt, *args):
    return '%s(%s)' % (self.__class__.__name__, fmt % args)

  def __repr__(self):
    return self.repr_format('%r', self._kwargs)

  @classmethod
  def of(cls, _name, *args, **kwargs):
    newcls = type(_name, (cls,), {})
    return newcls(*args, **kwargs)


class Insn(Node):

  def apply(self, ctx):
    if self.name not in OPCODE_NAMES:
      raise ValueError('Invalid instruction: %s' % self.name)

    ctx.allocator.align(1)
    result = None
    candidates = []
    exceptions = []
    for o in sorted(OPCODES, key=lambda x: x.code):
      if o.name == self.name and len(o.operands) == len(self.args):
        candidates.append(o)
        try:
          result = o.emit(*[Evaluable.eval(a) for a in self.args])
          if result:
            print('0x%04x: %04x\t%s %r\t\t; line %d' % (
              ctx.allocator.address, result, o.name, self.args, self.lineno))
            break
        except ValueError as e:
          pass
    if result is None:
      if not candidates:
        raise ValueError('line %d: %r with args %r: No candidates found: %r' % (
          self.lineno, self.name, self.args, exceptions))
      raise ValueError('line %d: %r with %d arg(s) %r: No matching candidate in %r' % (
          self.lineno, self.name, len(self.args), self.args, candidates))

    ctx.allocator.allocate([result & 0xff, result >> 8])


class Decl(Node):

  pass


class Evaluable(Node):

  def evaluate(self):
    if hasattr(self, 'val'):
      if isinstance(self.val, Evaluable):
        return self.val.evaluate()
      return self.val
    raise NotImplementedError('Unable to evaluate %r' % self)

  def __repr__(self):
    try:
      v = self.evaluate()
      if hasattr(self, 'val'):
        return self.repr_format('%r = %r', v, self.val)
      return self.repr_format('%r = %s', v, super().__repr__())
    except Exception as e:
      return self.repr_format('%s: %r', super().__repr__(), e)

  def __add__(self, other):
    return BinOp(lineno=self.lineno, op='+', arg1=self, arg2=other)

  def __mul__(self, other):
    return BinOp(lineno=self.lineno, op='*', arg1=self, arg2=other)

  def __floordiv__(self, other):
    return BinOp(lineno=self.lineno, op='/', arg1=self, arg2=other)

  def __and__(self, other):
    return BinOp(lineno=self.lineno, op='&', arg1=self, arg2=other)

  @staticmethod
  def eval(x):
    if isinstance(x, Evaluable):
      return x.evaluate()
    return x


class Label(Evaluable):

  def apply(self, ctx):
    ctx.update_label(self)


class Reference(Evaluable):

  def evaluate(self):
    i = self.ctx.find_identifier(self.name, self.lineno)
    if not i:
      raise ValueError('Reference to unknown identifier %r at line %d' % (self.name, self.lineno))
    return i.evaluate()


class CurrentAddress(Evaluable):

  def __init__(self, lineno, section):
    super().__init__(lineno=lineno, section=section)

  def evaluate(self):
    return Address(self.section.allocator.address, self.section.name)


class Identifier(Evaluable):

  LABEL    = 1
  ALIAS    = 2
  ADDRESS  = 3

  def __init__(self, name, lineno, val=None, typ=None):
    super().__init__(name=name, lineno=lineno, val=val, typ=typ)

  def evaluate(self):
    if self.val is None:
      return '%s is None' % self.name
    return super().evaluate()

  def __repr__(self):
    try:
      v = self.evaluate()
      return self.repr_format('%r = %r', self.name, v)
    except Exception as e:
      return self.repr_format('%r = %r: %r', self.name, self.val, e)

  def apply(self, ctx):
    if isinstance(self.val, CurrentAddress):
      self.val.val = Address(ctx.allocator.address, ctx.current_section.name)


class BinOp(Evaluable):

  _OP = {
    '+': operator.add,
    '-': operator.sub,
    '*': operator.mul,
    '/': operator.floordiv,
    '&': operator.and_,
    '|': operator.or_,
  }

  def __init__(self, lineno, op, arg1, arg2):
    if op not in self._OP:
      raise ValueError('Unsupported op: %r' % op)
    super().__init__(lineno=lineno, op=op, arg1=arg1, arg2=arg2)

  def evaluate(self):
    v1 = self.arg1
    v2 = self.arg2
    if isinstance(self.arg1, Evaluable):
      v1 = v1.evaluate()
    if isinstance(self.arg2, Evaluable):
      v2 = v2.evaluate()
    try:
      return self._OP[self.op](v1, v2)
    except TypeError as e:
      raise TypeError('%r: %r' % (self, e))

  def __repr__(self):
    return self.repr_format('%r %s %r', self.arg1, self.op, self.arg2)


class AsmLexer(Lexer):
  tokens = {
    ID, NUMBER, CHAR, STRING, OPCODE, BITSEL, BYTESEL,
    SECTION, ALIGN, DS, DD, EQU, ORG, ACC, RELREF,
    NL
   }
  literals = { '+','-','*','/','#',',','(',')',"'",'.','$',':','=' }

  STRING = r'"(\\.|[^\\"\n])*"'
  ID = r'\.?[a-zA-Z_@][a-zA-Z0-9_@]*'
  ID['.CODE'] = SECTION
  ID['.DATA'] = SECTION
  ID['.CONST'] = SECTION
  ID['.ALIGN'] = ALIGN
  ID['EQU'] = EQU
  ID['ORG'] = ORG
  ID['MOV'] = OPCODE
  ID['DS'] = DS
  ID['DB'] = DD
  ID['DW'] = DD
  ID['A'] = ACC
  ID['@B'] = RELREF
  ID['@F'] = RELREF
  BYTESEL = r'\$[LMH]'

  ignore = ' \t'
  ignore_comment1 = r';.*'
  ignore_comment2 = r'//.*'

  def __init__(self, ctx):
    super().__init__()
    self.ctx = ctx

  def STRING(self, t):
    # Drop leading and trailing '"'
    t.value = t.value[1:-1]
    return t

  @_(r'\n+')
  def NL(self, t):
    self.lineno += len(t.value)
    self.linestart = t.index
    return t

  @_(r'\.[0-7]')
  def BITSEL(self, t):
    t.value = int(t.value.strip('.'))
    return t

  @_(r'-?0x[0-9a-fA-F]+',
     r'-?\d+')
  def NUMBER(self, t):
    if t.value.startswith('0x'):
        t.value = int(t.value[2:], 16)
    else:
        t.value = int(t.value)
    return t

  @_(r"'.'")
  def CHAR(self, t):
    t.value = ord(t.value.strip("'").encode('ascii'))
    t.type = 'NUMBER'
    return t

  def ID(self, t):
    if t.value in OPCODE_NAMES:
      t.type = 'OPCODE'
      return t
    return t

  def error(self, t):
    print("Line %d: Illegal character '%s'" % (self.lineno, t.value[0]))
    self.index += 1


class AsmParser(Parser):
  debugfile = 'parser.dbg.txt'
  tokens = AsmLexer.tokens

  def __init__(self, ctx):
    super().__init__()
    self.ctx = ctx

  @_('statements statement',
     'statement')
  def statements(self, p):
    if hasattr(p, 'statements'):
      return p[0] + (p[1],)
    return (p[0],)

  @_('label',
     'declaration',
     'instruction',
     'align',
     'org',
     'section')
  def statement(self, p):
    self.ctx.current_section.statements.append(p[0])
    return p[0]

  @_('SECTION eol')
  def section(self, p):
    name = p[0]
    section = self.ctx.sections.setdefault(name, Section(name=name))
    self.ctx.current_section = section
    return Node.of('Section', lineno=p.lineno, name=name)

  @_('ID ":" eol')
  def label(self, p):
    return self.ctx.add_label(name=p.ID, lineno=p.lineno)

  @_('ID EQU expr eol',
     'ID "=" expr eol')
  def declaration(self, p):
    return self.ctx.add_identifier(name=p.ID, val=p.expr, lineno=p.lineno, typ=Identifier.ALIAS)

  @_('ID DS expr eol',
     'DS expr eol')
  def declaration(self, p):
    if hasattr(p, 'ID'):
      l = self.ctx.add_label(name=p.ID, lineno=p.lineno)
      return Node.of('DefineSpace', lineno=p.lineno, name=p.ID, size=p.expr, label=l)
    return Node.of('DefineSpace', lineno=p.lineno, name=None, size=p.expr)

  @_('ID DD expr_list eol',
     'DD expr_list eol')
  def declaration(self, p):
    if hasattr(p, 'ID'):
      l = self.ctx.add_label(name=p.ID, lineno=p.lineno)
      return Node.of('DefineData', lineno=p.lineno, name=p.ID, typ=p.DD, args=p.expr_list, label=l)
    return Node.of('DefineData', lineno=p.lineno, name=None, typ=p.DD, args=p.expr_list)

  @_('expr_list "," expr',
     'expr')
  def expr_list(self, p):
    if hasattr(p, 'expr_list'):
      return p.expr_list + (p.expr,)
    return (p.expr,)

  @_('ORG expr eol')
  def org(self, p):
    return Node.of('Org', expr=p.expr, lineno=p.lineno)

  @_('ALIGN expr eol')
  def align(self, p):
    return Node.of('Align', expr=p.expr, lineno=p.lineno)


  @_('RELREF')
  def relref(self, p):
    # Resolved lazily
    return Reference(name=p.RELREF, ctx=self.ctx, lineno=p.lineno)

  @_('OPCODE oparg_list eol',
     'OPCODE eol')
  def instruction(self, p):
    if hasattr(p, 'oparg_list'):
      return Insn(name=p[0], lineno=p.lineno, args=p.oparg_list)
    return Insn(name=p[0], lineno=p.lineno, args=[])

  @_('oparg_list "," oparg',
     'oparg')
  def oparg_list(self, p):
    if hasattr(p, 'oparg_list'):
      return p.oparg_list + (p.oparg,)
    return (p.oparg,)

  @_('imm',
     'expr',
     'ACC')
  def oparg(self, p):
    if hasattr(p, 'ACC'):
      return _ACC
    return p[0]

  @_('"#" expr')
  def imm(self, p):
    return Immediate(p.expr)

  @_('expr "+" term',
     'expr "-" term',
     'term')
  def expr(self, p):
    if hasattr(p, 'expr'):
      return BinOp(lineno=p.lineno, op=p[1], arg1=p.expr, arg2=p.term)
    return p.term

  @_('term "*" factor',
     'term "/" factor',
     'factor')
  def term(self, p):
    if hasattr(p, 'term'):
      return BinOp(lineno=p.lineno, op=p[1], arg1=p.term, arg2=p.factor)
    return p.factor

  @_('NUMBER',
     'ID',
     'STRING',
     'bitaddress',
     'maskedaddress',
     'currentaddress',
     'relref',
     '"(" expr ")"')
  def factor(self, p):
    if hasattr(p, 'ID'):
      return Reference(name=p.ID, ctx=self.ctx, lineno=p.lineno)
    if hasattr(p, 'expr'):
      return p.expr
    return p[0]

  @_('"$"')
  def currentaddress(self, p):
    return CurrentAddress(lineno=p.lineno, section=self.ctx.current_section)

  @_('ID BITSEL',
     'NUMBER BITSEL')
  def bitaddress(self, p):
    if hasattr(p, 'NUMBER'):
      return p.NUMBER * 8 + p.BITSEL
    return Reference(name=p.ID, ctx=self.ctx, lineno=p.lineno) * 8 + p.BITSEL

  @_('ID BYTESEL')
  def maskedaddress(self, p):
    div = {
      '$L': 0x00001,
      '$M': 0x00100,
      '$H': 0x10000,
    }.get(p.BYTESEL)
    return (Reference(lineno=p.lineno, name=p.ID, ctx=self.ctx) // div) & 0xff

  @_('NL',
     'eol NL')
  def eol(self, p):
    return p.NL

  def error(self, p):
    if not p:
      print('Syntax error: unexpected end of file')
      return
    tokens = ['%s=%r' % (p.type, p.value)]
    for i in range(3):
      tok = next(self.tokens, None)
      if not tok:
        break
      tokens.append('%s=%r' % (tok.type, tok.value))
    print('Syntax error at line %d state %d tokens: %s' % (p.lineno, self.state, ' '.join(tokens)))


if __name__ == '__main__':
  with open('main.s', 'r') as f:
    data = f.read()
  ctx = Context()
  lexer = AsmLexer(ctx)
  parser = AsmParser(ctx)
  result = parser.parse(lexer.tokenize(data))
  if not result:
    raise ValueError

  unresolved = []
  for k, v in ctx.identifiers.items():
    if not v.typ:
      print('Unresolved identifier %r on line %d: %r' % (k, v.lineno, v))
      unresolved.append(v)
  assert not unresolved

  last_hash = None
  new_hash = 0
  npass = 0
  while last_hash != new_hash:
    last_hash = new_hash
    new_hash = 0
    npass += 1
    print(f'Pass {npass}')

    for section in ctx.sections.values():
      section.allocator.reset()

    ctx.current_section = None
    for statement in result:
      ctx.apply(statement)

    for section in ctx.sections.values():
      new_hash ^= hash(section.allocator)

  for name, section in ctx.sections.items():
    print('Section: %r' % name)
    fname = name.strip('.')
    with open(f'{fname}.bin', 'wb') as f:
      for r in sorted(section.allocator.allocated, key=lambda x: x.start):
        f.seek(r.start)
        f.write(bytes(r.data))
        print('Range: %r' % r)
