require 'analysis/arm'
require 'analysis/helpers'

module Trans
  VHDL_IN = "regs_in"
  VHDL_OUT = "regs_out"

  $written_regs = {}
  $written_regs_new = {}
  $mentioned_regs = []

  ##################################################
  #API
  ##################################################

  def self.treg_newpar
    $written_regs.clear
    $written_regs_new.clear
    $mentioned_regs.clear
    (0..13).map { |i| $written_regs["r#{i}"] = "#{VHDL_IN}(#{i})" }
    $written_regs_new = $written_regs.clone
  end

  def self.treg_in(par)
    []
  end

  def self.treg_post_line
    $written_regs = $written_regs_new.clone
    []
  end

  def self.treg_out(par, par_trans)
    (0..13).map { |i| "#{VHDL_OUT}(#{i}) <= #{$written_regs["r#{i}"]};" }
  end

  def self.treg_used
    $mentioned_regs
  end

  def self.treg(l, reg, off = 0, write=false)
    if write then
      reg_name ="#{reg}_#{l[:addr].to_s(16)}"
      $written_regs_new[reg] = reg_name
      $mentioned_regs.push reg_name
      return $written_regs_new[reg]
    else
      return $written_regs[reg]
    end
  end

  def self.trans(l)
    [self.do_trans(l)].flatten.reject{|l| l.nil?}
  end

  ##################################################
  #Internal
  ##################################################
  private
  def self.check_args_rr(args)
    args.length >= 2 && is_reg(args[0]) && is_reg(args[1])
  end

  def self.check_args_rrr(args)
    args.length >= 3 && is_reg(args[0]) && is_reg(args[1]) && is_reg(args[2])
  end

  def self.check_args_rrrr(args)
    args.length >= 4 && is_reg(args[0]) && is_reg(args[1]) && is_reg(args[2]) && is_reg(args[3])
  end

  def self.do_trans(l)
    base = instr_base(l[:instr])

    return trans_dp(l) if ARM::DP_INSNS.include? base
    return trans_mul(l) if ARM::MUL_INSNS.include? base

    return "-- #{l[:instr]}@#{l[:addr].to_s(16)}"
    #raise CantTranslateError
  end

  $added_temps = []

  def self.trans_dp(l)
    raise "DP args error #{l[:args]}" unless check_args_rr(l[:args])

    dst = l[:args][0]
    reg1 = treg(l, l[:args][1])

    if l[:args].length == 2 then
      #mov or mvn
      case l[:instr]
      when "mov"
        return "#{dst} <= #{reg1};"
      when "mvn"
        return "#{dst} <= not #{reg1};"
      end
    else
      if l[:args][2][0] == 'r' then
        reg2 = treg(l, l[:args][2])
        if l[:args].length == 3 then
          #dst, reg, reg type
        else
          #dst, reg, reg, shift-thing
          shift = l[:args][3].split(" ")

          temp_name = "t_#{l[:addr].to_s(16)}_s"
          $added_temps.push temp_name
          line_shift = "#{temp_name} := std_logic_vector(unsigned(#{reg2}) #{ARM::SHIFT_INSNS_MAP[shift[0]]} TO_INTEGER(unsigned(#{treg(l, shift[1])})));"
          reg2 = temp_name

        end
      elsif l[:args][2][0] == '#'
        #dst, reg, imm type
        reg2 = l[:args][2][1,]
      end

      #fixups
      n1 = "not " if l[:instr] == "orn"
      n2 = "not" if l[:instr] == "bic"

      if l[:instr] == "rsb" then
        t = reg1
        reg1 = reg2
        reg2 = t
      end

      i_parts = l[:instr].split(".")
      instr = i_parts[0]
      #trailing S?
      if instr[-1] == 's' then
        #update flags?
        instr = instr[0..instr.length-2]
      end
      raise "UnknownDPInstruction #{l[:instr]} -> #{instr}" unless ARM::DP_INSNS_MAP.include? instr
      return [line_shift, "#{treg(l, dst, 1, true)} := std_logic_vector(#{n1}unsigned(#{reg1}) #{ARM::DP_INSNS_MAP[instr]} #{n2}unsigned(#{reg2}));"]
    end
  end

  def self.trans_mul(l)
    raise "MulArgsError #{l[:args]}" unless check_args_rrr(l[:args])

    dst = l[:args][0]
    rn = l[:args][1]
    rm = l[:args][2]

    case l[:instr]
    when "mla"
      ra = l[:args][3]
      return "#{treg(l, dst, 1, true)} := std_logic_vector(RESIZE(unsigned(#{treg(l, rn)}) * unsigned(#{treg(l, rm)}) + unsigned(#{treg(l, ra)}), 32));"
    when "mls"
      ra = l[:args][3]
      return "#{treg(l, dst, 1, true)} := #{treg(l, ra)} - #{treg(l, rn)} * #{treg(l, rm)};"
    when "mul"
      return "#{treg(l, dst, 1, true)} := #{treg(l, rn)} * #{treg(l, rm)};"
    else
      #TODO: do the rest of them
      return "-- #{l[:instr]}"
    end
  end
end
