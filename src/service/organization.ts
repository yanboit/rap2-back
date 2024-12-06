import seq from '../models/sequelize'
import Pagination from '../routes/utils/pagination'
import Utils from './utils'
export default class OrganizationService {
  public static canUserAccessOrganization(userId: number, organizationId: number): Promise<boolean> {
    const sql = `
      SELECT COUNT(id) AS num FROM (
        SELECT o.id, o.name
        FROM Organizations o
        WHERE ownerId = ${userId}
        UNION
        SELECT o.id, o.name
        FROM Organizations o
        JOIN organizations_members om ON o.id = om.organizationId
        WHERE om.userId = ${userId}
      ) as result
      WHERE id = ${organizationId}
    `
    return new Promise(resolve => {
      seq.query(sql).then((result: any) => {
        resolve(+result[0].num > 0);
      }).catch(() => {
        // 错误处理逻辑（如果没有需要处理的错误，可以为空）
      });
    });        
  }

  public static getAllOrganizationIdList(curUserId: number, pager: Pagination, query?: string): Promise<number[]> {
    if (query) {
      query = Utils.escapeSQL(query)
    }
    const sql = `
      SELECT id FROM (
        SELECT o.id, o.name
        FROM Organizations o
        WHERE visibility = ${1} OR ownerId = ${curUserId}
        UNION
        SELECT o.id, o.name
        FROM Organizations o
        JOIN organizations_members om ON o.id = om.organizationId
        WHERE om.userId = ${curUserId}
      ) as result
      ${query ? `WHERE id = '${query}' OR name LIKE '%${query}%'` : ''}
      ORDER BY id desc
      LIMIT ${pager.start}, ${pager.limit}
    `
    return new Promise(resolve => {
      seq.query(sql).then((result: [unknown[], unknown]) => {
        const ids = result[0].map((item: { id: number }) => item.id);
        resolve(ids);
      });
    });
    
  }

  public static getAllOrganizationIdListNum(curUserId: number): Promise<number> {
    const sql = `
      SELECT count(*) AS num FROM (
        SELECT o.id, o.name
        FROM Organizations o
        WHERE visibility = ${1} OR ownerId = ${curUserId}
        UNION
        SELECT o.id, o.name
        FROM Organizations o
        JOIN organizations_members om ON o.id = om.organizationId
        WHERE om.userId = ${curUserId}
      ) as result
      ORDER BY id desc
    `
    return new Promise(resolve => {
      seq.query(sql).then(([result]: [unknown[], unknown]) => {
        // 这里可以强制转换 result 为 { num: number }[] 类型
        resolve((result as { num: number }[])[0].num);
      });
    });    
    
  }
}