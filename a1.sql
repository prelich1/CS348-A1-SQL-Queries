--1
select s.snum, s.sname \ 
from student s, mark m \
where s.snum = m.snum \
	and m.cnum like 'CS2__' \
	and m.grade >= 80 \
	and s.year >= 3 \
group by s.snum, s.sname \
having count(*) >= 2

--2
select p.pnum, p.pname \
from professor p \
where p.dept = 'CS' \
	and p.pnum not in ( \
		select c.pnum \
		from class c \
		where c.cnum = 'CS240' or c.cnum = 'CS245' \
	)

--3
select p.pnum, p.pname \
from professor p, class c, \
	 ( select m.term, m.section, max(m.grade) \
           from mark m \
           where m.cnum = 'CS245' \
           group by m.term, m.section \
         ) as max_mark \
where p.pnum = c.pnum \
	and c.cnum = 'CS245' \
	and c.term = max_mark.term \
	and c.section = max_mark.section

--4
select s.snum, s.sname \
from student s, \
	(select m.snum, min(m.grade) as grade \
         from mark m \
         where (m.cnum like 'CS%' or m.cnum like 'CO%') \
         group by m.snum \
	) as min_mark \
where s.snum = min_mark.snum \
	and s.year = 4 \
	and min_mark.grade >= 85

--5
select p.dept \
from professor p \
where p.dept not in ( \
		select p.dept \
         	from professor p, class c, mark m \
                where p.pnum = c.pnum \
                        and not c.cnum like concat(p.dept, '%') \
                group by p.dept \
		) \
order by p.dept

--6
with \
	min_mark(snum, mingrade) as ( \
		select m.snum, min(m.grade) \
		from student s, mark m \
		where s.snum = m.snum \
			and s.year = 2 \
			and m.cnum like '__1__' \
		group by m.snum \
	), \
	total_students_min_60(total) as ( \
		select count(*) \
	        from min_mark m \
       	 	where m.mingrade >= 60 \
	), \
	total_students(total) as ( \
		select count(*) \
	        from student s \
        	where s.year = 2 \
	) \
select 100.0 * tot60.total / tot.total as percentage_of_2nd_years \
from total_students_min_60 tot60, total_students tot	

--7
select m.cnum, c.cname, m.term, count(*) as students, avg(m.grade) as avg_grade \
from mark m, enrollment e, course c \
where m.cnum = e.cnum and m.snum = e.snum and c.cnum = e.cnum \
group by m.cnum, c.cname, m.term

--9
with \
	max_grade(cnum, term, section, grade) as ( \
		select m.cnum, m.term, m.section, max(m.grade) \
		from mark m \
		group by m.cnum, m.term, m.section \
	), \
	min_grade(cnum, term, section, grade) as ( \
                select m.cnum, m.term, m.section, min(m.grade) \
                from mark m \
                group by m.cnum, m.term, m.section \
        ) \
select c1.cnum, c1.term, c1.section as c1_section, c1.pnum as p1_num, p1.pname as p1_name, max1.grade as p1_max_grade, min1.grade as p1_min_grade, c2.section as c2_section, c2.pnum as p2_num, p2.pname as p2_name, max2.grade as p2_max_grade, min2.grade as p2_min_grade \
from class c1, class c2, max_grade max1, max_grade max2, min_grade min1, min_grade min2, professor p1, professor p2 \
where c1.cnum = c2.cnum  and c1.term = c2.term and c1.pnum <> c2.pnum \
	and max1.cnum = c1.cnum and max1.term = c1.term and max1.section = c1.section \
	and max2.cnum = c2.cnum and max2.term = c2.term and max2.section = c2.section \
	and min1.cnum = c1.cnum and min1.term = c1.term and min1.section = c1.section \
        and min2.cnum = c2.cnum and min2.term = c2.term and min2.section = c2.section \
	and p1.pnum = c1.pnum and p2.pnum = c2.pnum \
order by c1.cnum 

--10
with \
	multiple_classes(pnum, term, cnum) as ( \
		select  c1.pnum, c1.term, c1.cnum \
        	from class c1, class c2 \
        	where c1.cnum = c2.cnum and c1.pnum = c2.pnum and c1.term = c2.term and c1.section <> c2.section \
        	group by c1.pnum, c1.term, c1.cnum \
	), \
	profs_with_gt_2_courses(pnum, term, num_diff_courses) as ( \
		select mc.pnum, mc.term, count(*) \
		from multiple_classes mc \
		group by mc.pnum, mc.term \
		having count(*) >= 2 \
	), \	
	profs_without_gt_2_courses(pnum) as ( \
		select p.pnum \
		from professor p \
		where p.pnum not in ( \
			select p2c.pnum \ 
			from profs_with_gt_2_courses p2c \
		) \
	), \
	total_profs_wt_2_courses(total) as ( \
		select count(*) \
		from profs_without_gt_2_courses p_wt_gt_2 \
	), \
	total_profs(total) as ( \
		select count(*) \
		from professor p \
	) \
select 100.0 * tot_p_wt_2.total / tot_p.total as percentage_of_profs \
from total_profs tot_p, total_profs_wt_2_courses tot_p_wt_2
