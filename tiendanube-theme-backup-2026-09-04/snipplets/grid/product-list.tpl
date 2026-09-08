 {% set noFilterResult = "No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros." %}

 {% if products %}
    <div class="js-product-table row row-grid">
        {% include 'snipplets/product_grid.tpl' %}
    </div>
    {% if settings.pagination == 'infinite' %}
        {% set pagination_type_val = true %}
    {% else %}
        {% set pagination_type_val = false %}
    {% endif %}

    {% include "snipplets/grid/pagination.tpl" with {infinite_scroll: pagination_type_val} %}
{% else %}    
    <h5 class="mb-4 font-weight-normal text-center" data-component="filter.message">
         {% if template == 'category' %}
            {{(has_filters_enabled ? noFilterResult : "Próximamente") | translate}}
        {% elseif template == 'search' %}    
            {{ ((has_applied_filters and query) or has_applied_filters ?  noFilterResult : "Escribilo de otra forma y volvé a intentar.") | translate }}
        {% endif %}
    </h5>
{% endif %} 