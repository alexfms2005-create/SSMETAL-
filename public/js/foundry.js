document.addEventListener('DOMContentLoaded',()=>{
    const clock=document.getElementById('clock');
    if(clock) setInterval(()=>{clock.textContent=new Intl.DateTimeFormat('es-MX',{dateStyle:'short',timeStyle:'medium',timeZone:'America/Mexico_City'}).format(new Date());},1000);
    const picker=document.getElementById('order-picker'), weight=document.getElementById('ot-weight'), furnace=document.getElementById('furnace-picker'), quantity=document.getElementById('ot-quantity');
    if(picker){
        const refresh=(updateWeight)=>{const option=picker.selectedOptions[0]; const model=option?.dataset.kind==='modelo'; furnace.disabled=model; weight.disabled=model; weight.required=!!option?.value&&!model; quantity.disabled=!model; quantity.required=model; if(model&&updateWeight)quantity.value=option.dataset.quantity; furnace.required=!!option?.value&&!model; if(model)furnace.value=''; if(updateWeight&&option?.dataset.weight) weight.value=option.dataset.weight;};
        picker.addEventListener('change',()=>refresh(true)); refresh(!weight.value);
    }
    document.querySelectorAll('form').forEach(form=>form.addEventListener('submit',()=>{if(!form.checkValidity())return; const button=form.querySelector('button[type="submit"],button:not([type])');if(button){button.disabled=true;button.dataset.label=button.textContent;button.textContent='Procesando…';}}));
    window.addEventListener('pageshow',()=>document.querySelectorAll('button[data-label]').forEach(b=>{b.disabled=false;b.textContent=b.dataset.label;}));
});
