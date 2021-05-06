; ModuleID = 'zad7.cpp'
source_filename = "zad7.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Base = type <{ i32 (...)**, i32, [4 x i8] }>
%struct.Derived = type { %struct.Base.base, [4 x i8] }
%struct.Base.base = type <{ i32 (...)**, i32 }>

$_ZN4BaseC1Ei = comdat any

$_ZN7DerivedC1Ei = comdat any

$_ZN4BaseC2Ei = comdat any

$_ZN4Base4doitEi = comdat any

$_ZN7DerivedC2Ei = comdat any

$_ZN7Derived4doitEi = comdat any

$_ZTV4Base = comdat any

$_ZTS4Base = comdat any

$_ZTI4Base = comdat any

$_ZTV7Derived = comdat any

$_ZTS7Derived = comdat any

$_ZTI7Derived = comdat any

@_ZTV4Base = linkonce_odr unnamed_addr constant { [3 x i8*] } { [3 x i8*] [i8* null, i8* bitcast ({ i8*, i8* }* @_ZTI4Base to i8*), i8* bitcast (i32 (%struct.Base*, i32)* @_ZN4Base4doitEi to i8*)] }, comdat, align 8
@_ZTVN10__cxxabiv117__class_type_infoE = external global i8*
@_ZTS4Base = linkonce_odr constant [6 x i8] c"4Base\00", comdat, align 1
@_ZTI4Base = linkonce_odr constant { i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv117__class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @_ZTS4Base, i32 0, i32 0) }, comdat, align 8
@_ZTV7Derived = linkonce_odr unnamed_addr constant { [3 x i8*] } { [3 x i8*] [i8* null, i8* bitcast ({ i8*, i8*, i8* }* @_ZTI7Derived to i8*), i8* bitcast (i32 (%struct.Derived*, i32)* @_ZN7Derived4doitEi to i8*)] }, comdat, align 8
@_ZTVN10__cxxabiv120__si_class_type_infoE = external global i8*
@_ZTS7Derived = linkonce_odr constant [9 x i8] c"7Derived\00", comdat, align 1
@_ZTI7Derived = linkonce_odr constant { i8*, i8*, i8* } { i8* bitcast (i8** getelementptr inbounds (i8*, i8** @_ZTVN10__cxxabiv120__si_class_type_infoE, i64 2) to i8*), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @_ZTS7Derived, i32 0, i32 0), i8* bitcast ({ i8*, i8* }* @_ZTI4Base to i8*) }, comdat, align 8

; Function Attrs: noinline nounwind optnone
define i32 @_Z4doitP4Base(%struct.Base* %bp) #0 {
entry:
  %bp.addr = alloca %struct.Base*, align 8
  store %struct.Base* %bp, %struct.Base** %bp.addr, align 8
  %0 = load %struct.Base*, %struct.Base** %bp.addr, align 8
  %1 = bitcast %struct.Base* %0 to i32 (%struct.Base*, i32)***
  %vtable = load i32 (%struct.Base*, i32)**, i32 (%struct.Base*, i32)*** %1, align 8
  %vfn = getelementptr inbounds i32 (%struct.Base*, i32)*, i32 (%struct.Base*, i32)** %vtable, i64 0
  %2 = load i32 (%struct.Base*, i32)*, i32 (%struct.Base*, i32)** %vfn, align 8
  %call = call i32 %2(%struct.Base* %0, i32 1)
  ret i32 %call
}

; Function Attrs: noinline norecurse nounwind optnone
define i32 @main(i32 %argc, i8** %argv) #1 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %b = alloca %struct.Base, align 8
  %d = alloca %struct.Derived, align 8
  store i32 0, i32* %retval, align 4
  store i32 %argc, i32* %argc.addr, align 4
  store i8** %argv, i8*** %argv.addr, align 8
  call void @_ZN4BaseC1Ei(%struct.Base* %b, i32 10)
  call void @_ZN7DerivedC1Ei(%struct.Derived* %d, i32 20)
  %call = call i32 @_Z4doitP4Base(%struct.Base* %b)
  %0 = bitcast %struct.Derived* %d to %struct.Base*
  %call1 = call i32 @_Z4doitP4Base(%struct.Base* %0)
  %add = add nsw i32 %call, %call1
  ret i32 %add
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN4BaseC1Ei(%struct.Base* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Base*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Base* %this, %struct.Base** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Base*, %struct.Base** %this.addr, align 8
  %0 = load i32, i32* %n.addr, align 4
  call void @_ZN4BaseC2Ei(%struct.Base* %this1, i32 %0)
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN7DerivedC1Ei(%struct.Derived* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Derived*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Derived* %this, %struct.Derived** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Derived*, %struct.Derived** %this.addr, align 8
  %0 = load i32, i32* %n.addr, align 4
  call void @_ZN7DerivedC2Ei(%struct.Derived* %this1, i32 %0)
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN4BaseC2Ei(%struct.Base* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Base*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Base* %this, %struct.Base** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Base*, %struct.Base** %this.addr, align 8
  %0 = bitcast %struct.Base* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [3 x i8*] }, { [3 x i8*] }* @_ZTV4Base, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %0, align 8
  %data = getelementptr inbounds %struct.Base, %struct.Base* %this1, i32 0, i32 1
  %1 = load i32, i32* %n.addr, align 4
  store i32 %1, i32* %data, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr i32 @_ZN4Base4doitEi(%struct.Base* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Base*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Base* %this, %struct.Base** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Base*, %struct.Base** %this.addr, align 8
  %0 = load i32, i32* %n.addr, align 4
  %data = getelementptr inbounds %struct.Base, %struct.Base* %this1, i32 0, i32 1
  %1 = load i32, i32* %data, align 8
  %sub = sub nsw i32 %0, %1
  ret i32 %sub
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr void @_ZN7DerivedC2Ei(%struct.Derived* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Derived*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Derived* %this, %struct.Derived** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Derived*, %struct.Derived** %this.addr, align 8
  %0 = bitcast %struct.Derived* %this1 to %struct.Base*
  %1 = load i32, i32* %n.addr, align 4
  %add = add nsw i32 %1, 1
  call void @_ZN4BaseC2Ei(%struct.Base* %0, i32 %add)
  %2 = bitcast %struct.Derived* %this1 to i32 (...)***
  store i32 (...)** bitcast (i8** getelementptr inbounds ({ [3 x i8*] }, { [3 x i8*] }* @_ZTV7Derived, i32 0, inrange i32 0, i32 2) to i32 (...)**), i32 (...)*** %2, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone
define linkonce_odr i32 @_ZN7Derived4doitEi(%struct.Derived* %this, i32 %n) unnamed_addr #0 comdat align 2 {
entry:
  %this.addr = alloca %struct.Derived*, align 8
  %n.addr = alloca i32, align 4
  store %struct.Derived* %this, %struct.Derived** %this.addr, align 8
  store i32 %n, i32* %n.addr, align 4
  %this1 = load %struct.Derived*, %struct.Derived** %this.addr, align 8
  %0 = load i32, i32* %n.addr, align 4
  %1 = bitcast %struct.Derived* %this1 to %struct.Base*
  %data = getelementptr inbounds %struct.Base, %struct.Base* %1, i32 0, i32 1
  %2 = load i32, i32* %data, align 8
  %mul = mul nsw i32 %0, %2
  ret i32 %mul
}

attributes #0 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+cx8,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline norecurse nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+cx8,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
