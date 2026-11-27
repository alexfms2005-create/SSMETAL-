@props(['name','label','value'=>null,'type'=>'text','options'=>null,'required'=>false,'step'=>null,'min'=>null])
<label class="field"><span>{{ $label }} @if($required)<i>*</i>@endif</span>
@if($options!==null)<select name="{{ $name }}" {{ $required?'required':'' }} {{ $attributes }}><option value="">Seleccionar…</option>@foreach($options as $key=>$text)<option value="{{ $key }}" @selected((string)old($name,$value)===(string)$key)>{{ $text }}</option>@endforeach</select>
@elseif($type==='textarea')<textarea name="{{ $name }}" rows="3" {{ $attributes }}>{{ old($name,$value) }}</textarea>
@else<input type="{{ $type }}" name="{{ $name }}" value="{{ $type==='password'?'':old($name,$value) }}" @required($required) @if($step) step="{{ $step }}" @endif @if($min!==null) min="{{ $min }}" @endif {{ $attributes }}>@endif
</label>
