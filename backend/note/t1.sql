CREATE OR REPLACE FUNCTION hcm.f_report_income_deduct_sum_org(p_business_period_no character varying, p_node_no character varying, p_organize_id integer)
 RETURNS TABLE(row_no integer, business_period_no character varying, node_no character varying, node_display character varying, node_no_2 character varying, node_display_2 character varying, employee_code character varying, full_name character varying, income_salary numeric, income_ot numeric, income_per_month numeric, income_other numeric, income_with_tax numeric, income_no_tax numeric, income_salary_forward numeric, income_living numeric, income_bonus numeric, deduct_bank numeric, deduct_benefit numeric, deduct_sso numeric, deduct_pvf numeric, deduct_tax numeric, deduct_no_tax numeric, deduct_with_tax numeric, deduct_ppt numeric, comp_pvf numeric, comp_sso numeric, income numeric, deduct numeric, net_income numeric, sso_branch character varying)
 LANGUAGE plpgsql
AS $function$
declare
  v_cal_date date;
begin
  if coalesce(p_business_period_no,'') = '' or coalesce(p_node_no,'') = '' then
     begin
       return query
       select 1 as row_no,p_business_period_no as business_period_no,p_node_no as node_no,cast(null as varchar)as employee_code,cast(null as varchar)as full_name,cast(null as varchar)as node_no_2,cast(null as varchar)as node_display,cast(null as varchar)as node_display_2
             ,cast(0 as decimal)as income_salary,cast(0 as decimal)as income_ot,cast(0 as decimal) as income_per_month,cast(0 as decimal) as income_other,cast(0 as decimal) as income_with_tax,cast(0 as decimal)as income_no_tax
             ,cast(0 as decimal)as income_salary_forward,cast(0 as decimal)as income_living,cast(0 as decimal)as income_bonus,cast(0 as decimal)as deduct_bank,cast(0 as decimal)as deduct_benefit,cast(0 as decimal)as comp_sso
             ,cast(0 as decimal)as deduct_pvf,cast(0 as decimal) as deduct_tax,cast(0 as decimal)as deduct_no_tax,cast(0 as decimal)as deduct_ppt,cast(0 as decimal)as income,cast(0 as decimal)as deduct
             ,cast(0 as decimal)as net_income,cast(0 as decimal) as deduct_with_tax,cast(0 as decimal)as comp_pvf,cast(0 as decimal)as comp_sso;
     end;
  else
    begin
      select bmp.start_date
      into v_cal_date
      from hcm.business_module_period bmp
      join hcm.business_type_period btp on btp.business_period_no = bmp.business_period_no and btp.organize_id = p_organize_id
      where btp.business_period_no = p_business_period_no
      and bmp.organize_id = p_organize_id
      and bmp.business_module_type_no = 'PR_CUTOFF';
    end;

    return query
    select cast(row_number() over(order by tbl.node_group,tbl.node_order,coalesce(tbl.employee_code,'0') asc) as integer) as row_no,
           p_business_period_no,
           cast(tbl.node_no as varchar),
           cast(tbl.node_display as varchar),
           cast(tbl.node_no_2 as varchar),
           cast(tbl.node_display_2 as varchar),
           cast(tbl.employee_code as varchar),
           cast(tbl.full_name as varchar),
           tbl.income_salary,
           tbl.income_ot,
           tbl.income_per_month,
           tbl.income_other,
           tbl.income_with_tax,
           tbl.income_no_tax,
           tbl.income_salary_forward,
           tbl.income_living,
           tbl.income_bonus,
           tbl.deduct_bank,
           tbl.deduct_benefit,
           tbl.deduct_sso,
           tbl.deduct_pvf,
           tbl.deduct_tax,
           tbl.deduct_no_tax,
           tbl.deduct_with_tax,
           tbl.deduct_ppt,
           tbl.comp_pvf,
           tbl.comp_sso,
           tbl.income,
           tbl.deduct,
           tbl.net_income,
           cast(tbl.sso_branch  as varchar)
    from(select tbl1.node_no,
                tbl1.node_display,
                null as node_no_2,
                null as node_display_2,
                null as employee_code,
                null as full_name,
                tbl1.income_salary,
                tbl1.income_ot,
                tbl1.income_per_month,
                tbl1.income_other,
                tbl1.income_with_tax,
                tbl1.income_no_tax,
                tbl1.income_salary_forward,
                tbl1.income_living,
                tbl1.income_bonus,
                tbl1.deduct_bank,
                tbl1.deduct_benefit,
                tbl1.deduct_sso,
                tbl1.deduct_pvf,
                tbl1.deduct_tax,
                tbl1.deduct_no_tax,
                tbl1.deduct_with_tax,
                tbl1.deduct_ppt,
                tbl1.comp_pvf,
                tbl1.comp_sso,
                tbl1.income,
                tbl1.deduct,
                tbl1.net_income,
                tbl1.order_no as node_group,
                1 as node_order,'' as sso_branch
         from (select n.node_no,
                      n.order_no,
                      n.node_display,
                      sum(n_pay.income_salary) as income_salary,
                      sum(n_pay.income_ot) as income_ot,
                      sum(n_pay.income_per_month) as income_per_month,
                      sum(n_pay.income_other) as income_other,
                      sum(n_pay.income_with_tax) as income_with_tax,
                      sum(n_pay.income_no_tax) as income_no_tax,
                      sum(n_pay.income_salary_forward) as income_salary_forward,
                      sum(n_pay.income_living) as income_living,
                      sum(n_pay.income_bonus) as income_bonus,
                      sum(n_pay.deduct_bank) as deduct_bank,
                      sum(n_pay.deduct_benefit) as deduct_benefit,
                      sum(n_pay.deduct_sso) as deduct_sso,
                      sum(n_pay.deduct_pvf) as deduct_pvf,
                      sum(n_pay.deduct_tax) as deduct_tax,
                      sum(n_pay.deduct_no_tax) as deduct_no_tax,
                      sum(n_pay.deduct_with_tax) as deduct_with_tax,
                      sum(n_pay.deduct_ppt) as deduct_ppt,
                      sum(n_pay.comp_pvf) as comp_pvf,
                      sum(n_pay.comp_sso) as comp_sso,
                      sum(n_pay.income) as income,
                      sum(n_pay.deduct) as deduct,
                      sum(n_pay.net_income) as net_income
               from (select row_number() over(order by order_no asc) * 1000000 as row_no,
                            onl.node_no,
                            onl.node_display,
                            onl.order_no
                     from hcm.org_node_list_all onl
                     where onl.order_no like '%'||p_node_no||'%'
                     and onl.organize_id = p_organize_id
                     order by 1) n
               join (select e_payroll.node_no,
                            e_payroll.node_order,
                            sum(e_payroll.income_salary) as income_salary,
                            sum(e_payroll.income_ot) as income_ot,
                            sum(e_payroll.income_per_month) as income_per_month,
                            sum(e_payroll.income_other) as income_other,
                            sum(e_payroll.income_with_tax) as income_with_tax,
                            sum(e_payroll.income_no_tax) as income_no_tax,
                            sum(e_payroll.income_salary_forward) as income_salary_forward,
                            sum(e_payroll.income_living) as income_living,
                            sum(e_payroll.income_bonus) as income_bonus,
                            sum(e_payroll.deduct_bank) as deduct_bank,
                            sum(e_payroll.deduct_benefit) as deduct_benefit,
                            sum(e_payroll.deduct_sso) as deduct_sso,
                            sum(e_payroll.deduct_pvf) as deduct_pvf,
                            sum(e_payroll.deduct_tax) as deduct_tax,
                            sum(e_payroll.deduct_no_tax) as deduct_no_tax,
                            sum(e_payroll.deduct_with_tax) as deduct_with_tax,
                            sum(e_payroll.deduct_ppt) as deduct_ppt,
                            sum(e_payroll.comp_pvf) as comp_pvf,
                            sum(e_payroll.comp_sso) as comp_sso,
                            sum(e_payroll.income) as income,
                            sum(e_payroll.deduct) as deduct,
                            sum(e_payroll.net_income) as net_income
                     from (select emp.node_no,
                                  emp.node_order,
                                  payroll.employee_code,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_1' then payroll.amount else 0 end) as income_salary,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_2' then payroll.amount else 0 end) as income_ot,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_3' then payroll.amount else 0 end) as income_per_month,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_4' then payroll.amount else 0 end) as income_other,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_5' then payroll.amount else 0 end) as income_with_tax,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_6' then payroll.amount else 0 end) as income_no_tax,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_7' then payroll.amount else 0 end) as income_salary_forward,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_8' then payroll.amount else 0 end) as income_living,
                                  sum(case when payroll.rf_group_no = 'RFG0000001_9' then payroll.amount else 0 end) as income_bonus,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_1' then payroll.amount else 0 end) as deduct_bank,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_2' then payroll.amount else 0 end) as deduct_benefit,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_3' then payroll.amount else 0 end) as deduct_sso,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_4' then payroll.amount else 0 end) as deduct_pvf,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_5' then payroll.amount else 0 end) as deduct_tax,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_6' then payroll.amount else 0 end) as deduct_no_tax,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_7' then payroll.amount else 0 end) as deduct_with_tax,
                                  sum(case when payroll.rf_group_no = 'RFG0000002_8' then payroll.amount else 0 end) as deduct_ppt,
                                  sum(case when payroll.rf_group_no = 'RFG0000003_1' then payroll.amount else 0 end) as comp_pvf,
                                  sum(case when payroll.rf_group_no = 'RFG0000003_2' then payroll.amount else 0 end) as comp_sso,
                                  sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount else 0 end) as income,
                                  sum(case when payroll.rf_category_code = 'DEDUCT' then payroll.amount else 0 end) as deduct,
                                  sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount when payroll.rf_category_code = 'deduct' then payroll.amount * -1 else 0 end) as net_income
                           from (select empp.employee_code,
                                        rpfc.rf_category_code,
                                        rpfc.rf_category_name,
                                        rpfg.rf_group_no,
                                        rpfg.rf_group_name,
                                        sum(coalesce(empp.amount,0)) as amount
                                 from hcm.report_field_category rpfc
                                 join hcm.report_field_group rpfg on rpfg.rf_category_no = rpfc.rf_category_no and rpfg.organize_id = p_organize_id
                                 join hcm.report_field rpf on rpf.rf_group_no = rpfg.rf_group_no and rpf.organize_id = p_organize_id
                                 join (select onl.node_no,
                                              epb.employee_code,
                                               pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                                              position_order,
                                              onl.order_no as node_order,p.business_period_no,
                                              p.allowance_type,emp.organize_id,
                                              sum(cast(coalesce(hcm.decrypt_data (p.amount_encrypt),'0') as decimal(18,2))) as amount
                                       from hcm.payroll_monthly p
                                       join hcm.employee_profile emp  on p.employee_code = emp.employee_code and p.organize_id = emp.organize_id
                                        left join hcm.prefix_master pxm on emp.prefix_code=pxm.prefix_code and pxm.organize_id=emp.organize_id
                                       join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = emp.organize_id
                                                                      and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
                                                                      between epb.effective_date and epb .end_date
                                       join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = emp.organize_id
         		      	                                 and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end)
         			                                 between pbn.effective_date and pbn.end_date
                                       join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                                    onl.node_no,
                                                    onl.node_display,
                                                    onl.order_no
                                             from hcm.org_node_list_all onl
                                             where onl.order_no like '%'||p_node_no||'%'
                                             and onl.organize_id = p_organize_id
                                             order by 1) onl on onl.node_no = pbn.node_no

                                       join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                                       join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                                      where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                                       and p.business_period_no = p_business_period_no
                                       and  emp.organize_id = p_organize_id
                                        and coalesce(p.import_flag,'N') <> 'Y' 
                                       --and (emp.resign_date is null or emp.resign_date > v_cal_date)
                                       GROUP BY onl.node_no,
                                              epb.employee_code,
                                               pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname,
                                              position_order,
                                              onl.order_no ,
                                              p.business_period_no,
                                              p.allowance_type,emp.organize_id
                                         ) empp
                                         on empp.allowance_type = rpf.rf_value and  empp.organize_id = rpf.organize_id
                                 where rpfc.organize_id = p_organize_id
                                 group by empp.employee_code,
         	                          rpfc.rf_category_code,
         	                          rpfc.rf_category_name,
         	                          rpfg.rf_group_no,
         	                          rpfg.rf_group_name) payroll
                           join (select onl.node_no,
                                        epb.employee_code,
                                        (select alternate_name from hcm.prefix_master where prefix_code = emp.prefix_code and organize_id = p_organize_id)||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                                        position_order,
                                        onl.order_no as node_order
                                 from hcm.employee_profile emp
                                 join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = p_organize_id
         			                               and  ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			                               between epb.effective_date and epb .end_date
                                 join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = p_organize_id
         			                           and ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			                           between pbn.effective_date and pbn.end_date
                                 join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                              onl.node_no,
                                              onl.node_display,
                                              onl.order_no
                                       from hcm.org_node_list_all onl
                                       where onl.order_no like '%'||p_node_no||'%'
                                       and onl.organize_id = p_organize_id
                                       order by 1) onl	on  onl.node_no = pbn.node_no
                                 join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                                 join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                                 where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                                 --where-- pbx.emp_group_code = 'EG0001' -- Tencent --
                                 and
                                 emp.organize_id = p_organize_id
                                 --and (emp.resign_date is null or emp.resign_date > v_cal_date)
                                 ) emp on emp.employee_code=payroll.employee_code
                           group by payroll.employee_code,emp.node_no,emp.node_order) e_payroll
                     group by e_payroll.node_no,e_payroll.node_order) n_pay on n_pay.node_order like n.order_no||'%'
               group by n.node_no,n.order_no,n.node_display) tbl1

         union all

         select null as node_no,
                null as node_display,
                tbl2.node_no as node_no_2,
                tbl2.node_display as node_display_2,
                null as employee_code,
                null as full_name,
                tbl2.income_salary,
                tbl2.income_ot,
                tbl2.income_per_month,
                tbl2.income_other,
                tbl2.income_with_tax,
                tbl2.income_no_tax,
                tbl2.income_salary_forward,
                tbl2.income_living,
                tbl2.income_bonus,
                tbl2.deduct_bank,
                tbl2.deduct_benefit,
                tbl2.deduct_sso,
                tbl2.deduct_pvf,
                tbl2.deduct_tax,
                tbl2.deduct_no_tax,
                tbl2.deduct_with_tax,
                tbl2.deduct_ppt,
                tbl2.comp_pvf,
                tbl2.comp_sso,
                tbl2.income,
                tbl2.deduct,
                tbl2.net_income,
                tbl2.node_order as node_group,
                2 as node_order,'' as sso_branch
         from (select e_payroll.node_no,
                      e_payroll.node_order,
                      e_payroll.node_display,
                      sum(e_payroll.income_salary) as income_salary,
                      sum(e_payroll.income_ot) as income_ot,
                      sum(e_payroll.income_per_month) as income_per_month,
                      sum(e_payroll.income_other) as income_other,
                      sum(e_payroll.income_with_tax) as income_with_tax,
                      sum(e_payroll.income_no_tax) as income_no_tax,
                      sum(e_payroll.income_salary_forward) as income_salary_forward,
                      sum(e_payroll.income_living) as income_living,
                      sum(e_payroll.income_bonus) as income_bonus,
                      sum(e_payroll.deduct_bank) as deduct_bank,
                      sum(e_payroll.deduct_benefit) as deduct_benefit,
                      sum(e_payroll.deduct_sso) as deduct_sso,
                      sum(e_payroll.deduct_pvf) as deduct_pvf,
                      sum(e_payroll.deduct_tax) as deduct_tax,
                      sum(e_payroll.deduct_no_tax) as deduct_no_tax,
                      sum(e_payroll.deduct_with_tax) as deduct_with_tax,
                      sum(e_payroll.deduct_ppt) as deduct_ppt,
                      sum(e_payroll.comp_pvf) as comp_pvf,
                      sum(e_payroll.comp_sso) as comp_sso,
                      sum(e_payroll.income) as income,
                      sum(e_payroll.deduct) as deduct,
                      sum(e_payroll.net_income) as net_income
               from (select emp.node_no,
                            emp.node_order,
                            emp.node_display,
                            payroll.employee_code,
                            sum(case when payroll.rf_group_no = 'RFG0000001_1' then payroll.amount else 0 end) as income_salary,
                            sum(case when payroll.rf_group_no = 'RFG0000001_2' then payroll.amount else 0 end) as income_ot,
                            sum(case when payroll.rf_group_no = 'RFG0000001_3' then payroll.amount else 0 end) as income_per_month,
                            sum(case when payroll.rf_group_no = 'RFG0000001_4' then payroll.amount else 0 end) as income_other,
                            sum(case when payroll.rf_group_no = 'RFG0000001_5' then payroll.amount else 0 end) as income_with_tax,
                            sum(case when payroll.rf_group_no = 'RFG0000001_6' then payroll.amount else 0 end) as income_no_tax,
                            sum(case when payroll.rf_group_no = 'RFG0000001_7' then payroll.amount else 0 end) as income_salary_forward,
                            sum(case when payroll.rf_group_no = 'RFG0000001_8' then payroll.amount else 0 end) as income_living,
                            sum(case when payroll.rf_group_no = 'RFG0000001_9' then payroll.amount else 0 end) as income_bonus,
                            sum(case when payroll.rf_group_no = 'RFG0000002_1' then payroll.amount else 0 end) as deduct_bank,
                            sum(case when payroll.rf_group_no = 'RFG0000002_2' then payroll.amount else 0 end) as deduct_benefit,
                            sum(case when payroll.rf_group_no = 'RFG0000002_3' then payroll.amount else 0 end) as deduct_sso,
                            sum(case when payroll.rf_group_no = 'RFG0000002_4' then payroll.amount else 0 end) as deduct_pvf,
                            sum(case when payroll.rf_group_no = 'RFG0000002_5' then payroll.amount else 0 end) as deduct_tax,
                            sum(case when payroll.rf_group_no = 'RFG0000002_6' then payroll.amount else 0 end) as deduct_no_tax,
                            sum(case when payroll.rf_group_no = 'RFG0000002_7' then payroll.amount else 0 end) as deduct_with_tax,
                            sum(case when payroll.rf_group_no = 'RFG0000002_8' then payroll.amount else 0 end) as deduct_ppt,
                            sum(case when payroll.rf_group_no = 'RFG0000003_1' then payroll.amount else 0 end) as comp_pvf,
                            sum(case when payroll.rf_group_no = 'RFG0000003_2' then payroll.amount else 0 end) as comp_sso,
                            sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount else 0 end) as income,
                            sum(case when payroll.rf_category_code = 'DEDUCT' then payroll.amount else 0 end) as deduct,
                            sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount when payroll.rf_category_code = 'DEDUCT' then payroll.amount * -1 else 0 end) as net_income
                     from (select prm.employee_code,
                                  rpfc.rf_category_code,
                                  rpfc.rf_category_name,
                                  rpfg.rf_group_no,
                                  rpfg.rf_group_name,
                                  sum(coalesce(prm.amount,0)) as amount
                           from hcm.report_field_category rpfc
                           join hcm.report_field_group rpfg on rpfg.rf_category_no = rpfc.rf_category_no and rpfg.organize_id = p_organize_id
                           join hcm.report_field rpf on rpf.rf_group_no = rpfg.rf_group_no and rpf.organize_id = p_organize_id
                           join (select onl.node_no,
                                        epb.employee_code,
                                         pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                                        position_order,
                                        onl.order_no as node_order,
                                        p.business_period_no,
                                        p.allowance_type,emp.organize_id,
                                        sum(cast(coalesce(hcm.decrypt_data (p.amount_encrypt),'0') as decimal(18,2))) as amount
                                 from hcm.payroll_monthly p
                                 join hcm.employee_profile emp  on p.employee_code = emp.employee_code and p.organize_id = emp.organize_id
                                 left join hcm.prefix_master pxm on emp.prefix_code=pxm.prefix_code and pxm.organize_id=p_organize_id
                                 join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = p_organize_id
                                                                and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
                                                                between epb.effective_date and epb .end_date
                                 join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = p_organize_id
         		      	                           and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end)
         			                           between pbn.effective_date and pbn.end_date
                                 join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                              onl.node_no,
                                              onl.node_display,
                                              onl.order_no
                                       from hcm.org_node_list_all onl
                                       where onl.order_no like '%'||p_node_no||'%'
                                       and onl.organize_id = p_organize_id
                                       order by 1) onl on onl.node_no = pbn.node_no
                                 join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                                 join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                                where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                                 and  emp.organize_id = p_organize_id
                                 and  p.business_period_no = p_business_period_no
                                  and coalesce(p.import_flag,'N') <> 'Y' 
                                 GROUP BY onl.node_no,
                                              epb.employee_code,
                                              pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname,
                                              position_order,
                                              onl.order_no ,
                                              p.business_period_no,
                                              p.allowance_type,emp.organize_id
                                 ) prm
                                       on prm.allowance_type = rpf.rf_value and prm.organize_id =  rpfc.organize_id

                           where rpfc.organize_id = p_organize_id
                           group by prm.employee_code,
         	                   rpfc.rf_category_code,
         	                   rpfc.rf_category_name,
         	                   rpfg.rf_group_no,
         	                   rpfg.rf_group_name) payroll
                     join (select onl.node_no,
                                  epb.employee_code,
                                  (select alternate_name from hcm.prefix_master where prefix_code = emp.prefix_code and organize_id = p_organize_id)||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                                  position_order,
                                  onl.order_no as node_order,
                                  onl.node_display
                           from hcm.employee_profile emp
                           join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = p_organize_id
         			                         and  ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			                         between epb.effective_date and epb .end_date
                           join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = p_organize_id
         			                     and ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			                     between pbn.effective_date and pbn.end_date
                           join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                        onl.node_no,
                                        onl.node_display,
                                        onl.order_no
                                 from hcm.org_node_list_all onl
                                 where onl.order_no like '%'||p_node_no||'%'
                                 and onl.organize_id = p_organize_id
                                 order by 1) onl	on  onl.node_no = pbn.node_no
                           join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                           join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                           where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                           --where
                           -- pbx.emp_group_code = 'EG0001' -- Tencent --
                           and emp.organize_id = p_organize_id
                           --and (emp.resign_date is null or emp.resign_date > v_cal_date)
                           ) emp on emp.employee_code=payroll.employee_code
                     group by payroll.employee_code,emp.node_no,emp.node_order,emp.node_display) e_payroll
               group by e_payroll.node_no,e_payroll.node_order,e_payroll.node_display) tbl2

         union all

         select null as node_no,
                null as node_display,
                null as node_no_2,
                null as node_display_2,
                tbl3.employee_code,
                tbl3.employee_name as full_name,
                tbl3.income_salary,
                tbl3.income_ot,
                tbl3.income_per_month,
                tbl3.income_other,
                tbl3.income_with_tax,
                tbl3.income_no_tax,
                tbl3.income_salary_forward,
                tbl3.income_living,
                tbl3.income_bonus,
                tbl3.deduct_bank,
                tbl3.deduct_benefit,
                tbl3.deduct_sso,
                tbl3.deduct_pvf,
                tbl3.deduct_tax,
                tbl3.deduct_no_tax,
                tbl3.deduct_with_tax,
                tbl3.deduct_ppt,
                tbl3.comp_pvf,
                tbl3.comp_sso,
                tbl3.income,
                tbl3.deduct,
                tbl3.net_income,
                tbl3.node_order as node_group,
                3 as node_order,coalesce(tbl3.branch_name,'-') as sso_branch
         from (select emp.node_no,
                      emp.node_order,
                      payroll.employee_code,
                      emp.employee_name,payroll.branch_name,
                      sum(case when payroll.rf_group_no = 'RFG0000001_1' then payroll.amount else 0 end) as income_salary,
                      sum(case when payroll.rf_group_no = 'RFG0000001_2' then payroll.amount else 0 end) as income_ot,
                      sum(case when payroll.rf_group_no = 'RFG0000001_3' then payroll.amount else 0 end) as income_per_month,
                      sum(case when payroll.rf_group_no = 'RFG0000001_4' then payroll.amount else 0 end) as income_other,
                      sum(case when payroll.rf_group_no = 'RFG0000001_5' then payroll.amount else 0 end) as income_with_tax,
                      sum(case when payroll.rf_group_no = 'RFG0000001_6' then payroll.amount else 0 end) as income_no_tax,
                      sum(case when payroll.rf_group_no = 'RFG0000001_7' then payroll.amount else 0 end) as income_salary_forward,
                      sum(case when payroll.rf_group_no = 'RFG0000001_8' then payroll.amount else 0 end) as income_living,
                      sum(case when payroll.rf_group_no = 'RFG0000001_9' then payroll.amount else 0 end) as income_bonus,
                      sum(case when payroll.rf_group_no = 'RFG0000002_1' then payroll.amount else 0 end) as deduct_bank,
                      sum(case when payroll.rf_group_no = 'RFG0000002_2' then payroll.amount else 0 end) as deduct_benefit,
                      sum(case when payroll.rf_group_no = 'RFG0000002_3' then payroll.amount else 0 end) as deduct_sso,
                      sum(case when payroll.rf_group_no = 'RFG0000002_4' then payroll.amount else 0 end) as deduct_pvf,
                      sum(case when payroll.rf_group_no = 'RFG0000002_5' then payroll.amount else 0 end) as deduct_tax,
                      sum(case when payroll.rf_group_no = 'RFG0000002_6' then payroll.amount else 0 end) as deduct_no_tax,
                      sum(case when payroll.rf_group_no = 'RFG0000002_7' then payroll.amount else 0 end) as deduct_with_tax,
                      sum(case when payroll.rf_group_no = 'RFG0000002_8' then payroll.amount else 0 end) as deduct_ppt,
                      sum(case when payroll.rf_group_no = 'RFG0000003_1' then payroll.amount else 0 end) as comp_pvf,
                      sum(case when payroll.rf_group_no = 'RFG0000003_2' then payroll.amount else 0 end) as comp_sso,
                      sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount else 0 end) as income,
                      sum(case when payroll.rf_category_code = 'DEDUCT' then payroll.amount else 0 end) as deduct,
                      sum(case when payroll.rf_category_code = 'INCOME' then payroll.amount when payroll.rf_category_code = 'DEDUCT' then payroll.amount * -1 else 0 end) as net_income
               from (select emp.employee_code,emp.branch_name,
                            rpfc.rf_category_code,
                            rpfc.rf_category_name,
                            rpfg.rf_group_no,
                            rpfg.rf_group_name,
                            sum(coalesce(emp.amount,0)) as amount
                     from hcm.report_field_category rpfc
                     join hcm.report_field_group rpfg on rpfg.rf_category_no = rpfc.rf_category_no and rpfg.organize_id = p_organize_id
                     join hcm.report_field rpf on rpf.rf_group_no = rpfg.rf_group_no and rpf.organize_id = p_organize_id
                     join (select onl.node_no,
                                  epb.employee_code,social.branch_name,
                                  pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                                  position_order,
                                  onl.order_no as node_order,p.business_period_no,
                                  p.allowance_type,emp.organize_id,
                                  sum(cast(coalesce(hcm.decrypt_data (p.amount_encrypt),'0') as decimal(18,2))) as amount
                           from hcm.payroll_monthly p
                           join hcm.employee_profile emp  on p.employee_code = emp.employee_code and p.organize_id = emp.organize_id
                           join hcm.employee_document doc on doc.employee_code = emp.employee_code and doc.organize_id = emp.organize_id
		           left join hcm.social_fund_branch social on social.branch_code = doc.social_branch_code and doc.organize_id = social.organize_id
			   left join hcm.prefix_master pxm on emp.prefix_code=pxm.prefix_code and pxm.organize_id=p_organize_id
                           join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = p_organize_id
                                                          and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
                                                          between epb.effective_date and epb .end_date
                           join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = p_organize_id
         			                     and (case when  emp.hiring_date > v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end)
         			                     between pbn.effective_date and pbn.end_date
                           join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                        onl.node_no,
                                        onl.node_display,
                                        onl.order_no
                                 from hcm.org_node_list_all onl
                                 where onl.order_no like '%'||p_node_no||'%'
                                 and onl.organize_id = p_organize_id
                                 order by 1) onl on onl.node_no = pbn.node_no
                           join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                           join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                           where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                           and emp.organize_id = p_organize_id
                           and p.business_period_no = p_business_period_no
                           and coalesce(p.import_flag,'N') <> 'Y' 
                           --and (emp.resign_date is null or emp.resign_date > v_cal_date)
                           GROUP BY onl.node_no,
                                  epb.employee_code,social.branch_name,
                                  pxm.alternate_name||emp.alternate_name||' '||emp.alternate_surname,
                                  position_order,
                                  onl.order_no ,p.business_period_no,
                                  p.allowance_type,emp.organize_id
                          ) emp on 1=1 and emp.allowance_type = rpf.rf_value and rpfc.organize_id = emp.organize_id

                     where rpfc.organize_id = p_organize_id
                     group by emp.employee_code,emp.branch_name,
         	             rpfc.rf_category_code,
         	             rpfc.rf_category_name,
         	             rpfg.rf_group_no,
         	             rpfg.rf_group_name) payroll
               join (select onl.node_no,
                            epb.employee_code,
                            pxm.alternate_name ||emp.alternate_name||' '||emp.alternate_surname as employee_name,
                            position_order,
                            onl.order_no as node_order
                     from hcm.employee_profile emp
		     left join hcm.prefix_master pxm on emp.prefix_code=pxm.prefix_code and pxm.organize_id=p_organize_id
                     join hcm.employee_position_box epb on epb.employee_code = emp.employee_code and epb.organize_id = p_organize_id
         			                   and  ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			                  between epb.effective_date and epb .end_date
                     join hcm.position_box_node pbn on epb.position_box_code = pbn.position_box_code and pbn.organize_id = p_organize_id
         			               and ( case when  emp.hiring_date >  v_cal_date then emp.hiring_date when (emp.resign_date < v_cal_date) then emp.resign_date  else v_cal_date end )
         			               between pbn.effective_date and pbn.end_date
                     join (select row_number() over(order by order_no asc) * 1000000 as row_no,
                                  onl.node_no,
                                  onl.node_display,
                                  onl.order_no
                           from hcm.org_node_list_all onl
                           where onl.order_no like '%'||p_node_no||'%'
                           and onl.organize_id = p_organize_id
                           order by 1) onl	on  onl.node_no = pbn.node_no
                     join hcm.position_box pbx on pbx.position_box_code = epb.position_box_code and pbx.organize_id = p_organize_id
                     join hcm.position_master pos on pos.position_code = pbx.position_code and pos.organize_id = p_organize_id
                     where pbx.emp_group_code = case p_organize_id when 14 then   'EG00000001' else pbx.emp_group_code end 
                     --where
                     --pbx.emp_group_code = 'EG0001' -- Tencent --
                     and emp.organize_id = p_organize_id
                     --and (emp.resign_date is null or emp.resign_date > v_cal_date)
                     ) emp on emp.employee_code=payroll.employee_code
               group by payroll.employee_code,emp.employee_name,payroll.branch_name,emp.node_no,emp.node_order) tbl3) tbl
         order by tbl.node_group
                 ,tbl.node_order
                 ,coalesce(tbl.employee_code,'0');
  end if;
end;
$function$
;
