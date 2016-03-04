
# line 1 "scrap.rl"
require 'cgi'
require 'uri'


# line 19 "scrap.rl"


class Nested
  
# line 13 "scrap.rb"
class << self
	attr_accessor :_nested_actions
	private :_nested_actions, :_nested_actions=
end
self._nested_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3
]

class << self
	attr_accessor :_nested_key_offsets
	private :_nested_key_offsets, :_nested_key_offsets=
end
self._nested_key_offsets = [
	0
]

class << self
	attr_accessor :_nested_trans_keys
	private :_nested_trans_keys, :_nested_trans_keys=
end
self._nested_trans_keys = [
	97, 0
]

class << self
	attr_accessor :_nested_single_lengths
	private :_nested_single_lengths, :_nested_single_lengths=
end
self._nested_single_lengths = [
	1
]

class << self
	attr_accessor :_nested_range_lengths
	private :_nested_range_lengths, :_nested_range_lengths=
end
self._nested_range_lengths = [
	0
]

class << self
	attr_accessor :_nested_index_offsets
	private :_nested_index_offsets, :_nested_index_offsets=
end
self._nested_index_offsets = [
	0
]

class << self
	attr_accessor :_nested_trans_targs
	private :_nested_trans_targs, :_nested_trans_targs=
end
self._nested_trans_targs = [
	0, 0, 0
]

class << self
	attr_accessor :_nested_trans_actions
	private :_nested_trans_actions, :_nested_trans_actions=
end
self._nested_trans_actions = [
	5, 7, 0
]

class << self
	attr_accessor :_nested_to_state_actions
	private :_nested_to_state_actions, :_nested_to_state_actions=
end
self._nested_to_state_actions = [
	1
]

class << self
	attr_accessor :_nested_from_state_actions
	private :_nested_from_state_actions, :_nested_from_state_actions=
end
self._nested_from_state_actions = [
	3
]

class << self
	attr_accessor :nested_start
end
self.nested_start = 0;
class << self
	attr_accessor :nested_first_final
end
self.nested_first_final = 0;
class << self
	attr_accessor :nested_error
end
self.nested_error = -1;

class << self
	attr_accessor :nested_en_main
end
self.nested_en_main = 0;


# line 23 "scrap.rl"

  def self.parse(s)
    stack = []

    data = s
    eof = data.length
    
# line 122 "scrap.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = nested_start
	ts = nil
	te = nil
	act = 0
end

# line 30 "scrap.rl"
    
# line 134 "scrap.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	end
	if _goto_level <= _resume
	_acts = _nested_from_state_actions[cs]
	_nacts = _nested_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _nested_actions[_acts - 1]
			when 1 then
# line 1 "NONE"
		begin
ts = p
		end
# line 164 "scrap.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _nested_key_offsets[cs]
	_trans = _nested_index_offsets[cs]
	_klen = _nested_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _nested_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _nested_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _nested_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _nested_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _nested_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _nested_trans_targs[_trans]
	if _nested_trans_actions[_trans] != 0
		_acts = _nested_trans_actions[_trans]
		_nacts = _nested_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _nested_actions[_acts - 1]
when 2 then
# line 11 "scrap.rl"
		begin
te = p+1
 begin 
      puts "1"
     end
		end
when 3 then
# line 15 "scrap.rl"
		begin
te = p+1
 begin 
      puts data[p]
     end
		end
# line 244 "scrap.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _nested_to_state_actions[cs]
	_nacts = _nested_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _nested_actions[_acts - 1]
when 0 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 264 "scrap.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 31 "scrap.rl"
  end
end

Nested.parse('abc')