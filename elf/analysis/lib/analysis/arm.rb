module ARM
  BRANCH_INSNS = ['bl', 'blx', 'bx', 'cbnz', 'cbz', 'b', 'tbb', 'tbh']
  BRANCH_SUFFIXES = ['eq', 'ne', 'cs', 'cc', 'mi', 'pl', 'vs', 'vc', 'hi', 'ls', 'ge', 'lt', 'gt', 'le']
  BRANCH_IT = ['it', 'itt', 'ite', 'itt', 'itet' ,'itte', 'itee', 'itttt', 'itett', 'ittet', 'iteet', 'ittte' ,'itete' ,'ittee', 'iteee']

  DP_INSNS_MAP = {'adc' => '+', 'add' => '+', 'and' => 'and', 'bic' => "&", 'eor' => 'xor', 'mov' => nil, 'mvn' => nil, 'orn' => 'or', 'orr' => 'or', 'rsb' => '-', 'sub' => '-'} #adr, cmn, cmp, rsc, sbc, teq, tst
  DP_INSNS = DP_INSNS_MAP.keys

  #TODO: deal with extend somewhere...
  SHIFT_INSNS_MAP = {'asr' => 'sra', 'lsl' => 'sll', 'lsr' => 'slr', 'ror' => 'ror', 'rrx' => 'ror'}
  SHIFT_INSNS = SHIFT_INSNS_MAP.keys

  MUL_INSNS = ['mla', 'mls', 'mul', 'smlabb', 'smlabt', 'smlatb', 'mslatt', 'smlad', 'smlal', 'smlalbb', 'smlalbt', 'smlaltb', 'smlaltt', 'smlald', 'smlawb', 'smlawt', 'smlsd', 'smlsld', 'smmla', 'smlls', 'smmul', 'smuad', 'smulbb', 'smulbt', 'smultb', 'smultt', 'smull', 'smulwb', 'smulwt', 'smusd', 'umaal', 'umlal', 'umull']
  SAT_INSNS = ['ssat', 'ssat16', 'usat', 'usat16', 'qadd', 'qsub', 'qdadd', 'qdsub']
  PACK_INSNS = ['pkh', 'sxtab', 'sxtab16', 'sxtah', 'sxtb', 'sxtb16', 'sxth', 'uxtab', 'uxtab16', 'uxtah', 'uxtb', 'uxtb16', 'uxth']
  PAR_INSNS = ['sadd16', 'qadd16', 'shadd16', 'uadd16', 'uqadd16', 'uhadd16', 'sasx', 'qasx', 'shasx', 'uasx', 'uqasx', 'uhasx', 'ssax', 'qsax', 'shsax', 'usax', 'uqsax', 'uhsax', 'ssub16', 'qsub16', 'shsub16', 'usub16', 'uqsub16', 'uhsub16', 'sadd8', 'qadd8', 'shad8', 'uadd8', 'uqadd8', 'uhadd8', 'ssub8', 'qsub8', 'shsub8', 'usub8', 'uqsub8', 'uhsub8']
  DIV_INSNS = ['sdiv', 'udiv']
  MISC_INSNS = ['bfc', 'bfi', 'clz', 'movt', 'rbit', 'rev', 'rev16', 'revsh', 'sbfx', 'sel', 'ubfx', 'usad8', 'usada8']
  LDST_INSNS = ['ldr', 'str', 'ldrt', 'strt', 'ldrex', 'strex', 'strh', 'strht', 'strexh', 'ldrh', 'ldrht', 'ldrexh', 'ldrsh', 'ldrsht', 'strb', 'strbt', 'strexb', 'ldrb', 'ldrbt', 'ldrexb', 'ldrsb', 'ldrsbt', 'ldrd', 'strd', 'ldrexd', 'strexd']
  LDSTMUL_INSNS = ['ldm', 'ldmia', 'ldmfd', 'ldmda', 'ldmfa', 'ldmdb', 'ldmea', 'ldmib', 'ldmed', 'pop', 'push', 'stm', 'stmia', 'stmea', 'stmda', 'stmed', 'stmdb', 'stmfd', 'stmib', 'stmfa']

  SIMD_LDST_INSNS = ['vldm', 'vldr', 'vstm', 'vstr', 'vdup', 'vmov', 'vmrs', 'vmsr']
  SIMD_PAR_INSNS = ['vadd', 'vaddhn', 'vaddl', 'vaddw', 'vhadd', 'vhsub', 'vpadal', 'vpadd', 'vpaddl', 'vraddhn', 'vrhadd', 'vrsubhn', 'vqadd', 'vqsub', 'vsub', 'vsubhn', 'vsubl', 'vsubw']
  SIMD_BIT_INSNS = ['vand', 'vbic', 'veor', 'vbif', 'vbit', 'vbsl', 'vmov', 'vmvn', 'vorr', 'vorn']
  SIMD_ADV_INSNS = ['vagce', 'vacgt', 'vacle', 'vaclt', 'vceq', 'vcge', 'vcgt', 'vcle'] #none: 'vtst'
  SIMD_SHIFT_INSNS = ['vqrshl', 'vqrshrn', 'vqrshrun', 'vqshl', 'vqshlu', 'vqshrn', 'vqshrun', 'vrshl', 'vrshr', 'vrsa', 'vrshn', 'vshl', 'vshll', 'vshr', 'vshrn', 'vsli', 'vsra', 'vsri']
  SIMD_MUL_INSNS = ['vmla', 'vmlal', 'vmls', 'vmlsl', 'vmul', 'vmull', 'vfma', 'vfms', 'vqdmlal', 'vqdmlsl', 'vqdmul', 'vqrdmulh', 'vqdmull']
  SIMD_MISC_INSNS = ['vaba', 'vabal', 'vabd', 'vabdl', 'vabs', 'vcvt', 'vcls', 'vclz', 'vcnt', 'vdup', 'vext', 'vmovn', 'vmovl', 'vmax', 'vmin', 'vneg', 'vpmax', 'vpmin', 'vrecpe', 'vrecps', 'vrsqrte', 'vrsqrts', 'vrev16', 'vrev32', 'vrev64', 'vqabs', 'vqmovn', 'vqmovun', 'vqneg', 'vswp', 'vtbl', 'vtbx', 'vtrn', 'vuzp', 'vzip']

  ARITH_INSNS = DP_INSNS + SHIFT_INSNS + MUL_INSNS + SAT_INSNS + PAR_INSNS + DIV_INSNS + MISC_INSNS
  SIMD_ARITH_INSNS = SIMD_PAR_INSNS + SIMD_BIT_INSNS + SIMD_SHIFT_INSNS + SIMD_MUL_INSNS + SIMD_ADV_INSNS + SIMD_MISC_INSNS

  ALL_ARITH_INSNS = ARITH_INSNS + SIMD_ARITH_INSNS
  ALL_LDST_INSNS = LDST_INSNS + LDSTMUL_INSNS + SIMD_LDST_INSNS

  #Used in loop detection
  CMP_INSNS = ['cmp', 'cmn']
  #TODO: not complete
  SIMPLE_ARITH_INSNS = ['add', 'sub', 'rsb', 'mul']
  MOV_INSNS = ['mov', 'mvn']
end
