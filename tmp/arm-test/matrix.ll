; ModuleID = 'matrix.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@veca = common global [64 x i32] zeroinitializer, align 16
@mata = common global [64 x [64 x i32]] zeroinitializer, align 16
@matb = common global [64 x [64 x i32]] zeroinitializer, align 16

; Function Attrs: nounwind
define i32 @vecop(i32* %vec, i32 %x) #0 {
entry:
  %retval = alloca i32, align 4
  %vec.addr = alloca i32*, align 8
  %x.addr = alloca i32, align 4
  %i = alloca i32, align 4
  store i32* %vec, i32** %vec.addr, align 8
  store i32 %x, i32* %x.addr, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 64
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load i32** %vec.addr, align 8
  %arrayidx = getelementptr inbounds i32* %2, i64 %idxprom
  %3 = load i32* %arrayidx, align 4
  %4 = load i32* %x.addr, align 4
  %mul = mul nsw i32 %3, %4
  %5 = load i32* %i, align 4
  %idxprom1 = sext i32 %5 to i64
  %6 = load i32** %vec.addr, align 8
  %arrayidx2 = getelementptr inbounds i32* %6, i64 %idxprom1
  store i32 %mul, i32* %arrayidx2, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %7 = load i32* %i, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %8 = load i32* %retval
  ret i32 %8
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.6.0 (tags/RELEASE_360/final)"}
