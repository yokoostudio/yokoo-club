<div class="js-addtocart js-addtocart-placeholder {% if not direct_add %}btn btn-primary btn-block{% endif %} btn-transition {{ custom_class }} disabled" style="display: none;">
    <div class="d-inline-block">
        <span class="js-addtocart-text">
            {% if direct_add %}
                <div class="d-flex justify-content-center align-items-center">
                    {% if direct_add %}
                        <div class="btn-link">
                    {% endif %}
                    {{ 'Comprar' | translate }}
                    {% if direct_add %}
                        </div>
                    {% endif %}
                    <svg class="icon-inline ml-1"><use xlink:href="#bag-small"/></svg>
                </div>
            {% else %}
                {{ 'Agregar al carrito' | translate }}
            {% endif %}
        </span>
        <span class="js-addtocart-success transition-container">
            {{ '¡Listo!' | translate }}
            <svg class="icon-inline font-body"><use xlink:href="#check"/></svg>
        </span>
        <div class="js-addtocart-adding transition-container transition-icon">
            <span class="js-addtocart-adding-text">{{ adding_text | default('Agregando' | translate) }}</span>
            <svg class="icon-inline icon-spin icon-w-2em ml-1"><use xlink:href="#spinner-third"/></svg>
        </div>
    </div>
</div>